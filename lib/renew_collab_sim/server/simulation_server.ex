defmodule RenewCollabSim.Server.SimulationServer do
  use GenServer

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
    Task.async(fn ->
      GenServer.call(pid, {:setup, simulation_id})
    end)
    |> Task.await()
  end

  def step(pid, simulation_id) do
    GenServer.cast(pid, {:step, simulation_id})
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
  def handle_cast(
        {:setup, simulation_id},
        %{project_id: project_id, processes: procs, pubsub_channels: pubsub_channels} = state
      ) do
    if Map.has_key?(procs, simulation_id) do
      {:noreply, state}
    else
      with {:ok, pid} <-
             RenewCollabSim.Server.SimulationProcess.start_monitor(simulation_id, [
               "simulation:#{simulation_id}" | pubsub_channels
             ]) do
        broadcast_state_change(state, project_id, simulation_id)

        {:noreply,
         %{
           state
           | processes:
               Map.put(procs, simulation_id, %{
                 sim_process: pid
               })
         }}
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
        %{project_id: project_id, processes: procs, pubsub_channels: pubsub_channels} = state
      ) do
    if Map.has_key?(procs, simulation_id) do
      {:noreply, state}
    else
      with {:ok, pid} <-
             RenewCollabSim.Server.SimulationProcess.start_monitor(simulation_id, pubsub_channels) do
        broadcast_state_change(state, project_id, simulation_id)

        {:reply, :ok,
         %{
           state
           | processes:
               Map.put(procs, simulation_id, %{
                 sim_process: pid
               })
         }}
      else
        _ ->
          {:reply, :error, state}
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
  def handle_call({:exists, simulation_id}, _from, %{processes: procs} = state) do
    {:reply, Map.has_key?(procs, simulation_id), state}
  end

  @impl true
  def handle_call({:is_playing, simulation_id}, _from, %{processes: procs} = state) do
    Map.get(procs, simulation_id, nil)
    |> case do
      %{sim_process: pid} -> RenewCollabSim.Server.SimulationProcess.is_playing(pid)
      nil -> false
    end
    |> then(&{:reply, &1, state})
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
  def handle_info(
        {:broadcast_shutdown, simulation_id},
        %{project_id: project_id, processes: procs} = state
      ) do
    broadcast_state_change(state, project_id, simulation_id)

    if Enum.empty?(procs), do: {:stop, :normal, state}, else: {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, %{processes: procs} = state) do
    for {simulation_id, %{sim_process: ^pid}} <- procs do
      Process.send_after(self(), {:broadcast_shutdown, simulation_id}, 0)
    end

    remaining =
      Map.filter(procs, fn
        {_, %{sim_process: ^pid}} -> false
        _ -> true
      end)

    {:noreply, %{state | processes: remaining}}
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

  defp cleanup(_reason, %{project_id: project_id, processes: procs} = state) do
    for {simulation_id, %{sim_process: pid}} <- procs do
      RenewCollabSim.Server.SimulationProcess.stop(pid)

      broadcast_state_change(state, project_id, simulation_id)
    end
  end

  defp broadcast_state_change(_state, project_id, simulation_id) do
    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "simulation:#{simulation_id}",
      {:simulation_change, simulation_id, :state}
    )

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "projects/#{project_id}/simulations",
      {:simulation_change, simulation_id, :state}
    )
  end
end
