defmodule RenewCollabSim.Server.SimulationServer do
  use GenServer

  @simulation_command_timeout 30_000

  def start_monitor(project_id, pubsub_channels) do
    with {:ok, pid} <-
           GenServer.start_link(__MODULE__, %{
             project_id: project_id,
             pubsub_channels: pubsub_channels
           }) do
      Process.monitor(pid)
      {:ok, pid}
    else
      e -> e
    end
  end

  def setup(pid, simulation_id) do
    GenServer.cast(pid, {:setup, simulation_id})
  end

  def setup_and_wait(pid, simulation_id) do
    timeout = setup_timeout()

    Task.async(fn ->
      GenServer.call(pid, {:setup, simulation_id}, timeout)
    end)
    |> Task.await(timeout + 1_000)
  end

  def step(pid, simulation_id) do
    GenServer.cast(pid, {:step, simulation_id})
  end

  def net_step(pid, simulation_id, net_instance_label) do
    GenServer.cast(pid, {:net_step, simulation_id, net_instance_label})
  end

  def console_command(pid, simulation_id, command) do
    safe_call(pid, {:console_command, simulation_id, command})
  end

  def transition_bindings(pid, simulation_id, net_instance_label, transition_id) do
    safe_call(pid, {:transition_bindings, simulation_id, net_instance_label, transition_id})
  end

  def fire_transition(pid, simulation_id, net_instance_label, transition_id, binding_index) do
    safe_call(
      pid,
      {:fire_transition, simulation_id, net_instance_label, transition_id, binding_index}
    )
  end

  def list_breakpoints(pid, simulation_id) do
    safe_call(pid, {:list_breakpoints, simulation_id})
  end

  def set_transition_breakpoint(pid, simulation_id, transition_id) do
    safe_call(pid, {:set_transition_breakpoint, simulation_id, transition_id})
  end

  def clear_transition_breakpoint(pid, simulation_id, transition_id) do
    safe_call(pid, {:clear_transition_breakpoint, simulation_id, transition_id})
  end

  def clear_breakpoints(pid, simulation_id) do
    safe_call(pid, {:clear_breakpoints, simulation_id})
  end

  def play(pid, simulation_id) do
    GenServer.cast(pid, {:play, simulation_id})
  end

  def pause(pid, simulation_id) do
    GenServer.cast(pid, {:pause, simulation_id})
  end

  def stop(pid, simulation_id) do
    GenServer.call(pid, {:stop, simulation_id})
  end

  def exists(pid, simulation_id) do
    GenServer.call(pid, {:exists, simulation_id})
  end

  def is_playing(pid, simulation_id) do
    GenServer.call(pid, {:is_playing, simulation_id})
  end

  def running_ids(pid) do
    GenServer.call(pid, :running_ids)
  end

  def count(pid) do
    GenServer.call(pid, :count)
  end

  def stop_all(pid) do
    GenServer.call(pid, :stop_all)
  end

  # Callbacks

  @impl true
  def init(%{project_id: project_id, pubsub_channels: pubsub_channels}) do
    {:ok, %{project_id: project_id, pubsub_channels: pubsub_channels, processes: %{}}}
  end

  @impl true
  def handle_continue({:broadcast, simulation_id}, state) do
    broadcast_state_change(state, simulation_id)

    {:noreply, state}
  end

  @impl true
  def handle_cast(
        {:setup, simulation_id},
        %{processes: procs, pubsub_channels: pubsub_channels} = state
      ) do
    if Map.has_key?(procs, simulation_id) do
      {:noreply, state}
    else
      with {:ok, pid} <-
             RenewCollabSim.Server.SimulationProcess.start_monitor(
               simulation_id,
               simulation_pubsub_channels(simulation_id, pubsub_channels)
             ) do
        {:noreply,
         %{
           state
           | processes:
               Map.put(procs, simulation_id, %{
                 sim_process: pid
               })
         }, {:continue, {:broadcast, simulation_id}}}
      else
        _ ->
          {:noreply, state}
      end
    end
  end

  @impl true
  def handle_cast({:step, simulation_id}, %{processes: procs} = state) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.step(p)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:net_step, simulation_id, net_instance_label}, %{processes: procs} = state) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.net_step(p, net_instance_label)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:play, simulation_id}, %{processes: procs} = state) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.play(p)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:pause, simulation_id}, %{processes: procs} = state) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.pause(p)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_call(
        {:setup, simulation_id},
        _from,
        %{processes: procs, pubsub_channels: pubsub_channels} = state
      ) do
    if Map.has_key?(procs, simulation_id) do
      {:reply, :ok, state}
    else
      with {:ok, pid} <-
             RenewCollabSim.Server.SimulationProcess.start_monitor(
               simulation_id,
               simulation_pubsub_channels(simulation_id, pubsub_channels)
             ) do
        {:reply, :ok,
         %{
           state
           | processes:
               Map.put(procs, simulation_id, %{
                 sim_process: pid
               })
         }, {:continue, {:broadcast, simulation_id}}}
      else
        error ->
          {:reply, error, state}
      end
    end
  end

  @impl true
  def handle_call({:stop, simulation_id}, _from, %{processes: procs} = state) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.stop(p)
        {:reply, true, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call(:stop_all, _from, %{processes: procs} = state) do
    for {_sim_id, %{sim_process: p}} <- procs do
      RenewCollabSim.Server.SimulationProcess.stop(p)
    end

    {:stop, :normal, :ok, state}
  end

  @impl true
  def handle_call({:console_command, simulation_id, command}, from, %{processes: procs} = state) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationProcess.console_command(p, command)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call(
        {:transition_bindings, simulation_id, net_instance_label, transition_id},
        from,
        %{processes: procs} = state
      ) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationProcess.transition_bindings(
              p,
              net_instance_label,
              transition_id
            )

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call(
        {:fire_transition, simulation_id, net_instance_label, transition_id, binding_index},
        from,
        %{processes: procs} = state
      ) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationProcess.fire_transition(
              p,
              net_instance_label,
              transition_id,
              binding_index
            )

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:list_breakpoints, simulation_id}, from, %{processes: procs} = state) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationProcess.list_breakpoints(p)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call(
        {:set_transition_breakpoint, simulation_id, transition_id},
        from,
        %{processes: procs} = state
      ) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationProcess.set_transition_breakpoint(p, transition_id)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call(
        {:clear_transition_breakpoint, simulation_id, transition_id},
        from,
        %{processes: procs} = state
      ) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationProcess.clear_transition_breakpoint(p, transition_id)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:clear_breakpoints, simulation_id}, from, %{processes: procs} = state) do
    case Map.get(procs, simulation_id, nil) do
      %{sim_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationProcess.clear_breakpoints(p)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:exists, simulation_id}, _from, %{processes: procs} = state) do
    {:reply, Map.has_key?(procs, simulation_id), state}
  end

  @impl true
  def handle_call({:is_playing, simulation_id}, from, %{processes: procs} = state) do
    Map.get(procs, simulation_id, nil)
    |> case do
      %{sim_process: pid} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationProcess.is_playing(pid)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call(:running_ids, _from, %{processes: procs} = state) do
    {:reply, Map.keys(procs), state}
  end

  @impl true
  def handle_call(:count, _from, %{processes: procs} = state) do
    {:reply, map_size(procs), state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, %{processes: procs} = state) do
    simulation_id =
      procs
      |> Enum.find_value(fn
        {simulation_id, %{sim_process: ^pid}} -> simulation_id
        _ -> nil
      end)

    remaining =
      Map.filter(procs, fn
        {_, %{sim_process: ^pid}} -> false
        _ -> true
      end)

    if simulation_id do
      {:noreply, %{state | processes: remaining}, {:continue, {:broadcast, simulation_id}}}
    else
      {:noreply, %{state | processes: remaining}}
    end
  end

  @impl true
  # handle the trapped exit call
  def handle_info({:EXIT, _from, reason}, state) do
    # cleanup(reason, state)
    # see GenServer docs for other return types
    {:stop, reason, state}
  end

  @impl true
  # handle termination
  def terminate(_reason, %{processes: procs} = state) do
    Enum.each(procs, fn {simulation_id, _} ->
      broadcast_state_change(state, simulation_id)
    end)

    :ok
  end

  defp broadcast_state_change(%{pubsub_channels: channels}, simulation_id) do
    for channel <- simulation_pubsub_channels(simulation_id, channels) do
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        channel,
        {:simulation_change, {simulation_id, :state}}
      )
    end
  end

  defp simulation_pubsub_channels(simulation_id, channels) do
    ["simulation:#{simulation_id}" | channels]
    |> Enum.uniq()
  end

  defp setup_timeout do
    :renew_collab
    |> Application.get_env(RenewCollabSim.Server, [])
    |> Keyword.get(:setup_timeout, 30_000)
  end

  defp safe_call(pid, message) do
    GenServer.call(pid, message, @simulation_command_timeout)
  catch
    :exit, {:timeout, _} -> {:error, :simulation_command_timed_out}
    :exit, reason -> {:error, reason}
  end
end
