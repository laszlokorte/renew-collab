defmodule RenewCollabSim.Simulator do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollabSim.Entites.ShadowNet
  alias RenewCollabSim.Entites.SimulationLogEntry
  alias RenewCollabSim.Entites.SimulationNetInstance
  alias RenewCollabSim.Entites.SimulationTransitionFiring
  alias RenewCollabSim.Entites.ShadowNetSystem
  alias RenewCollabSim.Entites.Simulation
  alias RenewCollabSim.Repo
  alias RenewCollab.Simulation.SimulationLink

  def list_shadow_net_systems do
    Repo.all(
      from(s in ShadowNetSystem,
        as: :ssn,
        left_join: nets in assoc(s, :nets),
        left_join: sims in assoc(s, :simulations),
        order_by: [desc: s.inserted_at],
        preload: [nets: nets],
        select: map(s, ^ShadowNetSystem.__schema__(:fields)),
        select_merge: %{
          simulation_count:
            subquery(
              from(sims in Simulation,
                where: sims.shadow_net_system_id == parent_as(:ssn).id,
                select: count(sims.id)
              )
            )
        }
      )
    )
  end

  def find_shadow_net_system(id) do
    Repo.one(
      from(s in ShadowNetSystem,
        left_join: nets in assoc(s, :nets),
        left_join: sims in assoc(s, :simulations),
        where: s.id == ^id,
        order_by: [desc: s.inserted_at, asc: sims.inserted_at],
        preload: [nets: nets, simulations: sims]
      )
    )
  end

  def find_all_simulations() do
    Repo.all(
      from(s in Simulation,
        inner_join: sns in assoc(s, :shadow_net_system),
        order_by: [desc: s.inserted_at],
        preload: [shadow_net_system: sns]
      )
    )
  end

  def find_simulation(id) do
    Repo.one(
      from(s in Simulation,
        join: sns in assoc(s, :shadow_net_system),
        left_join: nets in assoc(sns, :nets),
        left_join: ins in assoc(s, :net_instances),
        left_join: net in assoc(ins, :shadow_net),
        left_join: tokens in assoc(ins, :tokens),
        where: s.id == ^id,
        preload: [
          shadow_net_system: {sns, [nets: nets]},
          net_instances: {ins, [tokens: tokens, shadow_net: net]}
        ]
      )
    )
    |> Repo.preload(:log_entries)
    |> Repo.preload(net_instances: :firings)
  end

  def find_simulation_simple(id) do
    Repo.one(
      from(s in Simulation,
        join: sns in assoc(s, :shadow_net_system),
        left_join: nets in assoc(sns, :nets),
        left_join: ins in assoc(s, :net_instances),
        left_join: net in assoc(ins, :shadow_net),
        where: s.id == ^id,
        order_by: [asc: net.name, asc: ins.integer_id],
        preload: [
          shadow_net_system: {sns, [nets: nets]},
          net_instances: {ins, [shadow_net: net]}
        ]
      )
    )
  end

  def find_simulation_net_instance(simulation_id, net_name, integer_id) do
    Repo.one(
      from(ins in SimulationNetInstance,
        join: sim in assoc(ins, :simulation),
        join: net in assoc(ins, :shadow_net),
        left_join: tokens in assoc(ins, :tokens),
        left_join: firings in assoc(ins, :firings),
        on: firings.timestep == sim.timestep,
        where:
          ins.simulation_id == ^simulation_id and net.name == ^net_name and
            ins.integer_id == ^integer_id,
        order_by: [asc: firings.timestep],
        preload: [tokens: tokens, firings: firings, shadow_net: net]
      )
    )
  end

  def find_simulation_net_instance(net_instance_id) do
    Repo.one(
      from(ins in SimulationNetInstance,
        join: sim in assoc(ins, :simulation),
        join: net in assoc(ins, :shadow_net),
        left_join: tokens in assoc(ins, :tokens),
        left_join: firings in assoc(ins, :firings),
        on: firings.timestep == sim.timestep,
        where: ins.id == ^net_instance_id,
        order_by: [asc: firings.timestep],
        preload: [tokens: tokens, firings: firings, shadow_net: net]
      )
    )
  end

  def clear_log(id) do
    Repo.delete_all(
      from(l in SimulationLogEntry,
        where: l.simulation_id == ^id
      )
    )
  end

  def reset_time(id) do
    Repo.update_all(
      from(s in Simulation,
        where: s.id == ^id,
        update: [set: [timestep: 0]]
      ),
      []
    )
  end

  def clear_instances(id) do
    Repo.delete_all(
      from(l in SimulationNetInstance,
        where: l.simulation_id == ^id
      )
    )

    Repo.delete_all(
      from(l in SimulationTransitionFiring,
        where: l.simulation_id == ^id
      )
    )
  end

  def delete_shadow_net_system(id) do
    Repo.delete(find_shadow_net_system(id))
  end

  def delete_simulation(id) do
    Repo.delete(find_simulation(id))
    RenewCollabSim.Server.SimulationServer.terminate(id)

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "simulations",
      {:simulation_change, id, :delete}
    )
  end

  def create_and_start_simulation(shadow_net_system_id) do
    %RenewCollabSim.Entites.Simulation{
      shadow_net_system_id: shadow_net_system_id
    }
    |> Repo.insert()
    |> case do
      {:ok, %{id: id}} -> RenewCollabSim.Server.SimulationServer.setup(id)
    end
  end

  def create_simulation(shadow_net_system_id) do
    %RenewCollabSim.Entites.Simulation{
      shadow_net_system_id: shadow_net_system_id
    }
    |> Repo.insert()
    |> tap(fn
      {:ok, %{id: simulation_id}} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "simulations",
          {:simulation_change, simulation_id, :state}
        )
    end)
  end

  def change_main_net(sns_id, main_net_name) do
    find_shadow_net_system(sns_id)
    |> Ecto.Changeset.change(%{main_net_name: main_net_name})
    |> Repo.update()
  end

  def add_manual_log_entry(sim_id, content) do
    %RenewCollabSim.Entites.SimulationLogEntry{
      simulation_id: sim_id,
      content: content
    }
    |> Repo.insert()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "simulation:#{sim_id}",
      {:simulation_change, sim_id, :log}
    )
  end

  def change_net_document(
        shadow_net_system_id,
        shadow_net_id,
        document_id
      ) do
    RenewCollab.Renew.get_document_with_elements(document_id)
    |> case do
      nil ->
        nil

      doc ->
        with sn when not is_nil(sn) <-
               Repo.one(
                 from(sn in ShadowNet,
                   where:
                     sn.id == ^shadow_net_id and sn.shadow_net_system_id == ^shadow_net_system_id
                 )
               ),
             {:ok, doc_json} <-
               doc |> RenewCollabWeb.DocumentJSON.show_content() |> Jason.encode() do
          sn
          |> Ecto.Changeset.change(%{
            document_json: doc_json
          })
          |> Repo.update()
        end
    end
  end

  def compile_rnws_to_ssn(paths, main_net_name) do
    with {:ok, content} <- RenewCollabSim.Compiler.SnsCompiler.compile(paths) do
      create_shadow_net(
        content,
        main_net_name,
        Enum.map(paths, &%{"name" => Path.rootname(Path.basename(elem(&1, 0)))})
      )
    end
  end

  def create_shadow_net(content, main_net_name, nets) do
    sns =
      %RenewCollabSim.Entites.ShadowNetSystem{}
      |> RenewCollabSim.Entites.ShadowNetSystem.changeset(%{
        "compiled" => content,
        "main_net_name" => main_net_name,
        "nets" => nets
      })
      |> Repo.insert()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "shadow_nets",
      :any
    )

    sns
  end

  def create_simulation_from_documents(document_ids, main_net_name \\ nil) do
    nets =
      try do
        document_ids
        |> Enum.map(fn doc_id ->
          document = RenewCollab.Renew.get_document_with_elements(doc_id)
          {:ok, rnw} = RenewCollab.Export.DocumentExport.export(document, synthetic: true)
          {:ok, json} = RenewCollabWeb.DocumentJSON.show_content(document) |> Jason.encode()

          {RenewCollabSim.Compiler.SnsCompiler.normalize_net_name(document.name), rnw, json,
           {document.id, document.current_snaptshot.id}}
        end)
      rescue
        _e ->
          :export_error
      end

    with [{default_main_name, _, _, _} | _] <- nets,
         main_name <- main_net_name || default_main_name,
         {:ok, content} <-
           RenewCollabSim.Compiler.SnsCompiler.compile(
             nets
             |> Enum.map(fn {name, rnw, _, _} -> {name, rnw} end)
           ),
         {:ok, %{id: sns_id}} <-
           %RenewCollabSim.Entites.ShadowNetSystem{}
           |> RenewCollabSim.Entites.ShadowNetSystem.changeset(%{
             "compiled" => content,
             "main_net_name" => main_name,
             "nets" =>
               nets
               |> Enum.map(fn {name, _, json, _} ->
                 %{
                   "name" => name,
                   "document_json" => json
                 }
               end)
           })
           |> Repo.insert() do
      %RenewCollabSim.Entites.Simulation{
        shadow_net_system_id: sns_id
      }
      |> Repo.insert()
      |> case do
        {:ok, %{id: sim_id} = simulation} ->
          RenewCollabSim.Server.SimulationServer.setup(sim_id)

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "shadow_net:#{sns_id}",
            :any
          )

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "simulations",
            {:simulation_change, sim_id, :created}
          )

          now = DateTime.truncate(DateTime.utc_now(), :second)

          links =
            nets
            |> Enum.map(fn {_, _, _, {doc_id, snapshot_id}} ->
              %{
                document_id: doc_id,
                snapshot_id: snapshot_id,
                simulation_id: sim_id,
                inserted_at: now,
                updated_at: now
              }
            end)

          RenewCollab.Repo.insert_all(SimulationLink, links)

          for %{document_id: document_id} <- links do
            Phoenix.PubSub.broadcast(
              RenewCollab.PubSub,
              "document:#{document_id}",
              {:document_simulated, document_id}
            )
          end

          simulation

        e ->
          {:error, e}
      end
    end
  end
end
