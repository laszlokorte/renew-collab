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
  alias RenewCollab.Repo

  def list_shadow_net_systems do
    Repo.all(
      from(s in ShadowNetSystem,
        join: nets in assoc(s, :nets),
        left_join: sims in assoc(s, :simulations),
        order_by: [desc: s.inserted_at],
        preload: [nets: nets],
        select: map(s, ^ShadowNetSystem.__schema__(:fields)),
        select_merge: %{simulation_count: count(sims.id)}
      )
    )
  end

  def find_shadow_net_system(id) do
    Repo.one(
      from(s in ShadowNetSystem,
        join: nets in assoc(s, :nets),
        left_join: sims in assoc(s, :simulations),
        where: s.id == ^id,
        order_by: [desc: s.inserted_at, asc: sims.inserted_at],
        preload: [nets: nets, simulations: sims]
      )
    )
  end

  def find_simulation(id) do
    Repo.one(
      from(s in Simulation,
        left_join: logs in assoc(s, :log_entries),
        join: sns in assoc(s, :shadow_net_system),
        join: nets in assoc(sns, :nets),
        left_join: ins in assoc(s, :net_instances),
        left_join: tokens in assoc(ins, :tokens),
        left_join: firings in assoc(ins, :firings),
        where: s.id == ^id,
        order_by: [asc: logs.inserted_at, asc: fragment("?.rowid", logs), asc: firings.timestep],
        preload: [
          log_entries: logs,
          shadow_net_system: {sns, [nets: nets]},
          net_instances: {ins, [tokens: tokens, firings: firings]}
        ]
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
  end

  def change_main_net(sns_id, main_net_name) do
    find_shadow_net_system(sns_id)
    |> Ecto.Changeset.change(%{main_net_name: main_net_name})
    |> Repo.update()
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

          dbg("xxxx")
        end
    end
  end
end
