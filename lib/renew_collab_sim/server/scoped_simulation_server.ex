defmodule RenewCollabSim.Server.ScopedSimulationServer do
  alias RenewCollabSim.Server.SimulationServer
  use GenServer

  @simulation_command_timeout 30_000

  def start_link(_defaults) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def setup(simulation_scope, simulation_id, pubsub_channels) do
    GenServer.cast(__MODULE__, {:setup, simulation_scope, simulation_id, pubsub_channels})
  end

  def setup_and_wait(simulation_scope, simulation_id, pubsub_channels) do
    timeout = setup_timeout()

    Task.async(fn ->
      GenServer.call(
        __MODULE__,
        {:setup, simulation_scope, simulation_id, pubsub_channels},
        timeout
      )
    end)
    |> Task.await(timeout + 1_000)
  end

  def step(simulation_scope, simulation_id) do
    GenServer.cast(__MODULE__, {:step, simulation_scope, simulation_id})
  end

  def net_step(simulation_scope, simulation_id, net_instance_label) do
    GenServer.cast(__MODULE__, {:net_step, simulation_scope, simulation_id, net_instance_label})
  end

  def console_command(simulation_scope, simulation_id, command) do
    safe_call({:console_command, simulation_scope, simulation_id, command})
  end

  def transition_bindings(simulation_scope, simulation_id, net_instance_label, transition_id) do
    safe_call(
      {:transition_bindings, simulation_scope, simulation_id, net_instance_label, transition_id}
    )
  end

  def fire_transition(
        simulation_scope,
        simulation_id,
        net_instance_label,
        transition_id,
        binding_index
      ) do
    safe_call(
      {:fire_transition, simulation_scope, simulation_id, net_instance_label, transition_id,
       binding_index}
    )
  end

  def list_breakpoints(simulation_scope, simulation_id) do
    safe_call({:list_breakpoints, simulation_scope, simulation_id})
  end

  def set_transition_breakpoint(simulation_scope, simulation_id, transition_id) do
    safe_call({:set_transition_breakpoint, simulation_scope, simulation_id, transition_id})
  end

  def clear_transition_breakpoint(simulation_scope, simulation_id, transition_id) do
    safe_call({:clear_transition_breakpoint, simulation_scope, simulation_id, transition_id})
  end

  def clear_breakpoints(simulation_scope, simulation_id) do
    safe_call({:clear_breakpoints, simulation_scope, simulation_id})
  end

  def play(simulation_scope, simulation_id) do
    GenServer.cast(__MODULE__, {:play, simulation_scope, simulation_id})
  end

  def pause(simulation_scope, simulation_id) do
    GenServer.cast(__MODULE__, {:pause, simulation_scope, simulation_id})
  end

  def stop(simulation_scope, simulation_id) do
    GenServer.call(__MODULE__, {:stop, simulation_scope, simulation_id})
  end

  def stop_scope(simulation_scope) do
    GenServer.call(__MODULE__, {:stop_scope, simulation_scope})
  end

  def exists(simulation_scope, simulation_id) do
    GenServer.call(__MODULE__, {:exists, simulation_scope, simulation_id})
  end

  def is_playing(simulation_scope, simulation_id) do
    GenServer.call(__MODULE__, {:is_playing, simulation_scope, simulation_id})
  end

  def running_ids(simulation_scope) do
    GenServer.call(__MODULE__, {:running_ids, simulation_scope})
  end

  def count(simulation_scope) do
    GenServer.call(__MODULE__, {:count, simulation_scope})
  end

  def count_all() do
    GenServer.call(__MODULE__, :count_all)
  end

  # Callbacks

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_cast({:setup, simulation_scope, simulation_id, pubsub_channels}, state) do
    Map.get(state, simulation_scope)
    |> case do
      nil ->
        with {:ok, pid} <-
               RenewCollabSim.Server.SimulationServer.start_monitor(
                 simulation_scope,
                 pubsub_channels
               ) do
          RenewCollabSim.Server.SimulationServer.setup(pid, simulation_id)

          {:noreply,
           Map.put(state, simulation_scope, %{
             server_process: pid
           })}
        else
          _ ->
            {:noreply, state}
        end

      %{server_process: pid} ->
        RenewCollabSim.Server.SimulationServer.setup(pid, simulation_id)
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:step, simulation_scope, simulation_id}, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.step(p, simulation_id)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:net_step, simulation_scope, simulation_id, net_instance_label}, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.net_step(p, simulation_id, net_instance_label)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:play, simulation_scope, simulation_id}, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.play(p, simulation_id)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:pause, simulation_scope, simulation_id}, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.pause(p, simulation_id)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:setup, simulation_scope, simulation_id, pubsub_channels}, _from, state) do
    Map.get(state, simulation_scope)
    |> case do
      nil ->
        with {:ok, pid} <-
               RenewCollabSim.Server.SimulationServer.start_monitor(simulation_scope, [
                 "simulation:#{simulation_id}" | pubsub_channels
               ]),
             :ok <- RenewCollabSim.Server.SimulationServer.setup_and_wait(pid, simulation_id) do
          {:reply, :ok,
           Map.put(state, simulation_scope, %{
             server_process: pid
           })}
        else
          error ->
            {:reply, error, state}
        end

      %{server_process: pid} ->
        RenewCollabSim.Server.SimulationServer.setup_and_wait(pid, simulation_id)
        |> then(&{:reply, &1, state})
    end
  end

  @impl true
  def handle_call({:stop, simulation_scope, simulation_id}, _from, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.stop(p, simulation_id)
        {:reply, true, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:stop_scope, simulation_scope}, _from, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.stop_all(p)
        {:reply, true, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:console_command, simulation_scope, simulation_id, command}, from, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.console_command(p, simulation_id, command)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call(
        {:transition_bindings, simulation_scope, simulation_id, net_instance_label,
         transition_id},
        from,
        state
      ) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.transition_bindings(
              p,
              simulation_id,
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
        {:fire_transition, simulation_scope, simulation_id, net_instance_label, transition_id,
         binding_index},
        from,
        state
      ) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.fire_transition(
              p,
              simulation_id,
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
  def handle_call({:list_breakpoints, simulation_scope, simulation_id}, from, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.list_breakpoints(p, simulation_id)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call(
        {:set_transition_breakpoint, simulation_scope, simulation_id, transition_id},
        from,
        state
      ) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.set_transition_breakpoint(
              p,
              simulation_id,
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
        {:clear_transition_breakpoint, simulation_scope, simulation_id, transition_id},
        from,
        state
      ) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.clear_transition_breakpoint(
              p,
              simulation_id,
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
  def handle_call({:clear_breakpoints, simulation_scope, simulation_id}, from, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.clear_breakpoints(p, simulation_id)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:exists, simulation_scope, simulation_id}, from, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.exists(p, simulation_id)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:is_playing, simulation_scope, simulation_id}, from, state) do
    Map.get(state, simulation_scope, nil)
    |> case do
      %{server_process: pid} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.is_playing(pid, simulation_id)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      _ ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:running_ids, simulation_scope}, from, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.running_ids(p)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, MapSet.new(), state}
    end
  end

  @impl true
  def handle_call({:count, simulation_scope}, from, state) do
    case Map.get(state, simulation_scope, nil) do
      %{server_process: p} ->
        Task.start(fn ->
          result =
            RenewCollabSim.Server.SimulationServer.count(p)

          GenServer.reply(from, result)
        end)

        {:noreply, state}

      nil ->
        {:reply, 0, state}
    end
  end

  @impl true
  def handle_call(:count_all, _from, state) do
    sum =
      state
      |> Enum.map(fn {_, %{server_process: pid}} ->
        Task.async(fn -> SimulationServer.count(pid) end)
      end)
      |> Enum.map(&Task.await(&1, 1_000))
      |> Enum.sum()

    {:reply, {map_size(state), sum}, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    remaining =
      Map.filter(state, fn
        {_, %{server_process: ^pid}} -> false
        _ -> true
      end)

    {:noreply, remaining}
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
  def terminate(reason, state) do
    cleanup(reason, state)
    state
  end

  defp cleanup(_reason, state) do
    for {_scope_id, %{server_process: pid}} <- state do
      RenewCollabSim.Server.SimulationServer.stop_all(pid)
    end
  end

  defp setup_timeout do
    :renew_collab
    |> Application.get_env(RenewCollabSim.Server, [])
    |> Keyword.get(:setup_timeout, 30_000)
  end

  defp safe_call(message) do
    GenServer.call(__MODULE__, message, @simulation_command_timeout)
  catch
    :exit, {:timeout, _} -> {:error, :simulation_command_timed_out}
    :exit, reason -> {:error, reason}
  end
end
