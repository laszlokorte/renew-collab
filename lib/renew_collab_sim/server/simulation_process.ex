defmodule RenewCollabSim.Server.SimulationProcess do
  use GenServer

  alias RenewCollabSim.Repo

  def start_monitor(simulation_id) do
    with {:ok, pid} <-
           GenServer.start(__MODULE__, %{simulation_id: simulation_id, latest_update: nil}) do
      Process.monitor(pid)
      {:ok, pid}
    else
      e -> e
    end
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def is_playing(pid) do
    GenServer.call(pid, :is_playing)
  end

  def step(pid) do
    GenServer.cast(pid, :step)
  end

  def play(pid) do
    GenServer.cast(pid, :play)
  end

  def pause(pid) do
    GenServer.cast(pid, :pause)
  end

  defp broadcast_change(
         state = %{
           simulation_id: sim_id,
           latest_update: latest_update,
           retry: retry,
           playing: playing
         },
         event
       ) do
    now = DateTime.utc_now()

    if retry do
      Process.cancel_timer(retry)
    end

    if is_nil(latest_update) || DateTime.diff(now, latest_update, :millisecond) >= 100 do
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        "simulation:#{sim_id}",
        {:simulation_change, sim_id, {event, playing}}
      )

      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        "simulations",
        {:simulation_change, sim_id, {event, playing}}
      )

      %{state | latest_update: now, retry: nil}
    else
      %{state | retry: Process.send_after(self(), {:retry_broadcast, event}, 100)}
    end
  end

  @impl true
  def handle_info({:retry_broadcast, event}, state) do
    {:noreply, state |> broadcast_change(event)}
  end

  @impl true
  def handle_info(:auto_step, state) do
    GenServer.cast(self(), :step)
    {:noreply, %{state | scheduled: false}}
  end

  @impl true
  def init(%{simulation_id: simulation_id}) do
    try do
      simulation = RenewCollabSim.Simulator.find_simulation(simulation_id)
      {sim_process, directory} = init_process(simulation)

      {:ok,
       %{
         simulation: simulation,
         simulation_id: simulation_id,
         sim_process: sim_process,
         directory: directory,
         latest_update: nil,
         retry: nil,
         playing: false,
         scheduled: false,
         logging: true,
         open_multi: {0, Ecto.Multi.new()}
       }}
    rescue
      _ ->
        :ignore
    end
  end

  @impl true
  def handle_call(
        :is_playing,
        _from,
        state = %{
          playing: is_playing
        }
      ) do
    {:reply, is_playing, state}
  end

  @impl true
  def handle_call(
        :stop,
        _from,
        state = %{
          simulation_id: simulation_id,
          sim_process: sim_process,
          open_multi: {om_counter, open_multi}
        }
      ) do
    import Ecto.Query
    Process.exit(sim_process, :kill)

    now = DateTime.utc_now()

    open_multi
    |> Ecto.Multi.insert_all(
      {om_counter, :make_log_entry},
      RenewCollabSim.Entites.SimulationLogEntry,
      from(s in RenewCollabSim.Entites.Simulation,
        where: s.id == ^simulation_id,
        select: %{
          id: ^Ecto.UUID.generate(),
          simulation_id: s.id,
          content: ^"simulation stopped",
          inserted_at: ^now,
          updated_at: ^now
        }
      )
    )
    |> Ecto.Multi.delete_all(
      {om_counter, :delete_net_instances},
      from(i in RenewCollabSim.Entites.SimulationNetInstance,
        where: i.simulation_id == ^simulation_id
      )
    )
    |> Ecto.Multi.update_all(
      {om_counter, :reset_timestep},
      from(sim in RenewCollabSim.Entites.Simulation,
        where: sim.id == ^simulation_id,
        update: [set: [timestep: 0]]
      ),
      []
    )
    |> Repo.transaction()

    {:stop, :normal, :shutdown_ok, state |> broadcast_change(:stop)}
  end

  @impl true
  def handle_cast(
        {:log, {:exit, status}},
        state = %{simulation_id: simulation_id, open_multi: {om_counter, open_multi}}
      ) do
    import Ecto.Query
    now = DateTime.utc_now()

    open_multi
    |> Ecto.Multi.insert_all(
      {om_counter, :make_log_entry},
      RenewCollabSim.Entites.SimulationLogEntry,
      from(s in RenewCollabSim.Entites.Simulation,
        where: s.id == ^simulation_id,
        select: %{
          id: ^Ecto.UUID.generate(),
          simulation_id: s.id,
          content: ^"simulation process exit: #{status}",
          inserted_at: ^now,
          updated_at: ^now
        }
      )
    )
    |> Ecto.Multi.delete_all(
      {om_counter, :delete_net_instances},
      from(i in RenewCollabSim.Entites.SimulationNetInstance,
        where: i.simulation_id == ^simulation_id
      )
    )
    |> Ecto.Multi.update_all(
      {om_counter, :reset_timestep},
      from(sim in RenewCollabSim.Entites.Simulation,
        where: sim.id == ^simulation_id,
        update: [set: [timestep: 0]]
      ),
      []
    )
    |> Repo.transaction()

    {:stop, :normal, state |> broadcast_change(:stop)}
  end

  @impl true
  def handle_cast(:step, state = %{sim_process: sim_process}) do
    send(sim_process, {:command, "simulation step\n"})
    {:noreply, state}
  end

  @impl true
  def handle_cast(:play, state = %{sim_process: sim_process}) do
    # send(sim_process, {:command, "simulation run\n"})
    send(sim_process, {:command, "simulation step\n"})
    {:noreply, %{state | playing: true}}
  end

  @impl true
  def handle_cast(:pause, state = %{sim_process: _sim_process}) do
    # send(sim_process, {:command, "simulation stop\n"})
    {:noreply, %{state | playing: false}}
  end

  @new_instance ~r/\((?<ni_time_number>\d+)\)New net instance (?<ni_instance_name>[^\[]+)\[(?<ni_instance_number>\d+)\] created\./
  @init_token ~r/\((?<it_time_number>\d+)\)Initializing (?<it_value>\S+) into (?<it_instance_name>[^\[]+)\[(?<it_instance_number>\d+)\].(?<it_place_id>\S+)/
  @putting ~r/\((?<pt_time_number>\d+)\)Putting (?<pt_value>\S+) into (?<pt_instance_name>[^\[]+)\[(?<pt_instance_number>\d+)\].(?<pt_place_id>\S+)/
  @removing ~r/\((?<rm_time_number>\d+)\)Removing (?<rm_value>\S+) in (?<rm_instance_name>[^\[]+)\[(?<rm_instance_number>\d+)\].(?<rm_place_id>\S+)/
  @firing ~r/\((?<fr_time_number>\d+)\)Firing (?<fr_instance_name>[^\[]+)\[(?<fr_instance_number>\d+)\].(?<fr_transition_id>\S+)/
  @sync ~r/\((?<sc_time_number>\d+)\)-------- Synchronously --------/
  @setup ~r/(?<setup>Simulation set up,\s+)/

  @combined [@new_instance, @init_token, @putting, @removing, @firing, @sync, @setup]
            |> Enum.map(& &1.source)
            |> Enum.join("|")
            |> then(&"(:?Renew > )?(?:#{&1})")
            |> Regex.compile!("um")

  @impl true
  def handle_cast(
        {:log, {:noeol, content}},
        state = %{
          simulation_id: simulation_id,
          logging: logging,
          playing: playing,
          open_multi: {om_counter, _}
        }
      ) do
    import Ecto.Query

    state =
      if logging and not playing do
        state
        |> append_multi(
          Ecto.Multi.new()
          |> Ecto.Multi.insert(
            {om_counter, :log_entry},
            %RenewCollabSim.Entites.SimulationLogEntry{
              simulation_id: simulation_id,
              content: content
            }
          )
          |> Ecto.Multi.delete_all(
            {om_counter, :delete_old_logs},
            from(dt in RenewCollabSim.Entites.SimulationLogEntry,
              where:
                dt.simulation_id == ^simulation_id and
                  dt.id not in subquery(
                    from(t in RenewCollabSim.Entites.SimulationLogEntry,
                      select: t.id,
                      limit: 100,
                      order_by: [desc: t.inserted_at],
                      where: t.simulation_id == ^simulation_id
                    )
                  )
            )
          )
        )
      else
        state
      end

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:log, {:eol, content}},
        state = %{
          simulation_id: simulation_id,
          simulation: simulation,
          playing: playing,
          logging: logging,
          scheduled: scheduled,
          open_multi: {om_counter, open_multi}
        }
      ) do
    import Ecto.Query

    state =
      if logging and not playing do
        state
        |> append_multi(
          Ecto.Multi.new()
          |> Ecto.Multi.insert(
            {om_counter, :log_entry},
            %RenewCollabSim.Entites.SimulationLogEntry{
              simulation_id: simulation_id,
              content: content
            }
          )
          |> Ecto.Multi.delete_all(
            {om_counter, :delete_old_logs},
            from(dt in RenewCollabSim.Entites.SimulationLogEntry,
              where:
                dt.simulation_id == ^simulation_id and
                  dt.id not in subquery(
                    from(t in RenewCollabSim.Entites.SimulationLogEntry,
                      select: t.id,
                      limit: 100,
                      order_by: [desc: t.inserted_at],
                      where: t.simulation_id == ^simulation_id
                    )
                  )
            )
          )
        )
      else
        state
      end

    case Regex.named_captures(@combined, content) do
      %{
        "ni_time_number" => time_number,
        "ni_instance_name" => instance_name,
        "ni_instance_number" => instance_number
      }
      when "" != time_number ->
        {:noreply,
         state
         |> append_multi(
           Ecto.Multi.new()
           |> Ecto.Multi.insert_all(
             {om_counter, :create_net_instances},
             RenewCollabSim.Entites.SimulationNetInstance,
             from(sn in RenewCollabSim.Entites.ShadowNet,
               where:
                 sn.name == ^instance_name and
                   sn.shadow_net_system_id == ^simulation.shadow_net_system_id,
               select: %{
                 id: ^Ecto.UUID.generate(),
                 simulation_id: ^simulation_id,
                 label: ^"#{instance_name}[#{instance_number}]",
                 shadow_net_system_id: sn.shadow_net_system_id,
                 shadow_net_id: sn.id,
                 integer_id: ^instance_number
               }
             ),
             on_conflict: :replace_all
           )
           |> Ecto.Multi.delete_all(
             {om_counter, :delete_old_tokens},
             from(dt in RenewCollabSim.Entites.SimulationNetToken,
               where:
                 dt.simulation_net_instance_id in subquery(
                   from(i in RenewCollabSim.Entites.SimulationNetInstance,
                     select: i.id,
                     where:
                       i.simulation_id == ^simulation_id and
                         i.label == ^"#{instance_name}[#{instance_number}]"
                   )
                 )
             )
           )
         )}

      %{
        "it_time_number" => time_number,
        "it_instance_name" => instance_name,
        "it_instance_number" => instance_number,
        "it_value" => value,
        "it_place_id" => place_id
      }
      when "" != time_number ->
        {:noreply,
         state
         |> append_multi(
           Ecto.Multi.new()
           |> Ecto.Multi.insert_all(
             {om_counter, :init_tokens},
             RenewCollabSim.Entites.SimulationNetToken,
             from(n in RenewCollabSim.Entites.SimulationNetInstance,
               where:
                 n.label == ^"#{instance_name}[#{instance_number}]" and
                   n.simulation_id == ^simulation_id,
               select: %{
                 id: ^Ecto.UUID.generate(),
                 simulation_id: n.simulation_id,
                 simulation_net_instance_id: n.id,
                 place_id: ^place_id,
                 value: ^value
               }
             )
           )
         )}

      %{
        "pt_time_number" => time_number,
        "pt_instance_name" => instance_name,
        "pt_instance_number" => instance_number,
        "pt_value" => value,
        "pt_place_id" => place_id
      }
      when "" != time_number ->
        {:noreply,
         state
         |> append_multi(
           Ecto.Multi.new()
           |> Ecto.Multi.insert_all(
             {om_counter, :put_tokens},
             RenewCollabSim.Entites.SimulationNetToken,
             from(n in RenewCollabSim.Entites.SimulationNetInstance,
               where:
                 n.label == ^"#{instance_name}[#{instance_number}]" and
                   n.simulation_id == ^simulation_id,
               select: %{
                 id: ^Ecto.UUID.generate(),
                 simulation_id: n.simulation_id,
                 simulation_net_instance_id: n.id,
                 place_id: ^place_id,
                 value: ^value
               }
             )
           )
         )}

      %{
        "rm_time_number" => time_number,
        "rm_instance_name" => instance_name,
        "rm_instance_number" => instance_number,
        "rm_value" => value,
        "rm_place_id" => place_id
      }
      when "" != time_number ->
        {:noreply,
         state
         |> append_multi(
           Ecto.Multi.new()
           |> Ecto.Multi.delete_all(
             {om_counter, :remove_tokens},
             from(dt in RenewCollabSim.Entites.SimulationNetToken,
               where:
                 dt.id in subquery(
                   from(t in RenewCollabSim.Entites.SimulationNetToken,
                     select: t.id,
                     limit: 1,
                     join: i in assoc(t, :simulation_net_instance),
                     where:
                       t.value == ^value and
                         fragment("? = ?", t.place_id, ^place_id) and
                         t.simulation_id == ^simulation_id and
                         i.label == ^"#{instance_name}[#{instance_number}]"
                   )
                 )
             )
           )
         )}

      %{
        "fr_time_number" => time_number,
        "fr_instance_name" => instance_name,
        "fr_instance_number" => instance_number,
        "fr_transition_id" => transition_id
      }
      when "" != time_number ->
        {:noreply,
         state
         |> append_multi(
           Ecto.Multi.new()
           |> Ecto.Multi.insert_all(
             {om_counter, :track_firings},
             RenewCollabSim.Entites.SimulationTransitionFiring,
             from(n in RenewCollabSim.Entites.SimulationNetInstance,
               where:
                 n.label == ^"#{instance_name}[#{instance_number}]" and
                   n.simulation_id == ^simulation_id,
               select: %{
                 id: ^Ecto.UUID.generate(),
                 simulation_id: n.simulation_id,
                 simulation_net_instance_id: n.id,
                 transition_id: ^transition_id,
                 timestep: ^time_number
               }
             )
           )
         )}

      %{
        "sc_time_number" => time_number
      }
      when "" != time_number ->
        open_multi
        |> Ecto.Multi.update_all(
          {om_counter, :update_time},
          from(sim in RenewCollabSim.Entites.Simulation,
            where: sim.id == ^simulation_id,
            update: [set: [timestep: ^time_number]]
          ),
          []
        )
        |> Repo.transaction()

        state = %{state | open_multi: {0, Ecto.Multi.new()}}

        if playing and not scheduled do
          Process.send_after(self(), :auto_step, 100)

          {:noreply, %{state | scheduled: true} |> broadcast_change(:step)}
        else
          {:noreply, state |> broadcast_change(:step)}
        end

      %{
        "setup" => setup
      }
      when "" != setup ->
        open_multi
        |> Ecto.Multi.update_all(
          {om_counter, :reset_time},
          from(sim in RenewCollabSim.Entites.Simulation,
            where: sim.id == ^simulation_id,
            update: [set: [timestep: 1]]
          ),
          []
        )
        |> Repo.transaction()

        {:noreply, state |> broadcast_change(:init)}

      nil ->
        {:noreply, state}
    end
  end

  def append_multi(state = %{open_multi: {counter, open}}, multi) do
    %{state | open_multi: {counter + 1, open |> Ecto.Multi.append(multi)}}
  end

  @impl true
  # handle termination
  def terminate(
        _reason,
        state = %{simulation: _sim, directory: directory, sim_process: sim_process}
      ) do
    Process.exit(sim_process, :kill)
    File.rm_rf(directory)

    state |> broadcast_change(:stop)
  end

  defp init_process(simulation) do
    slf = self()
    uuid_dir = "renew-simulation-#{simulation.id}/#{UUID.uuid4(:default)}"

    {:ok, output_root} = Path.safe_relative_to(uuid_dir, System.tmp_dir!())
    output_root = Path.absname(output_root, System.tmp_dir!())

    {:ok, sns_path} = Path.safe_relative_to("compiled-shadow-net.ssn", output_root)
    {:ok, script_path} = Path.safe_relative_to("simulation-script", output_root)

    sns_path = Path.absname(sns_path, output_root)
    script_path = Path.absname(script_path, output_root)

    File.mkdir_p(output_root)

    script_content =
      [
        "startsimulation \"#{sns_path}\" \"#{simulation.shadow_net_system.main_net_name}\" -i"
      ]
      |> Enum.join("\n")

    File.write!(script_path, script_content)
    File.write!(sns_path, simulation.shadow_net_system.compiled)

    sim_process =
      RenewCollabSim.Script.Runner.start_and_collect(script_path, fn log ->
        GenServer.cast(slf, {:log, log})
      end)

    {sim_process, output_root}
  end
end
