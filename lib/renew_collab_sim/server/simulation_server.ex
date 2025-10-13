defmodule RenewCollabSim.Server.SimulationServer do
  use GenServer

  def start_link(_defaults) do
    GenServer.start_link(__MODULE__, %{})
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

  def terminate(pid, simulation_id) do
    GenServer.call(pid, {:terminate, simulation_id})
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

  # Callbacks

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_cast({:setup, simulation_id}, state) do
    if Map.has_key?(state, simulation_id) do
      {:noreply, state}
    else
      with {:ok, pid} <- RenewCollabSim.Server.SimulationProcess.start_monitor(simulation_id) do
        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "simulation:#{simulation_id}",
          {:simulation_change, simulation_id, :state}
        )

        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "simulations",
          {:simulation_change, simulation_id, :state}
        )

        {:noreply,
         Map.put(state, simulation_id, %{
           sim_process: pid
         })}
      else
        _ ->
          {:noreply, state}
      end
    end
  end

  @impl true
  def handle_cast({:step, simulation_id}, state) do
    case Map.get(state, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.step(p)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:play, simulation_id}, state) do
    case Map.get(state, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.play(p)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:pause, simulation_id}, state) do
    case Map.get(state, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.pause(p)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:setup, simulation_id}, _from, state) do
    if Map.has_key?(state, simulation_id) do
      {:noreply, state}
    else
      with {:ok, pid} <- RenewCollabSim.Server.SimulationProcess.start_monitor(simulation_id) do
        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "simulation:#{simulation_id}",
          {:simulation_change, simulation_id, :state}
        )

        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "simulations",
          {:simulation_change, simulation_id, :state}
        )

        {:reply, :ok,
         Map.put(state, simulation_id, %{
           sim_process: pid
         })}
      else
        _ ->
          {:reply, :error, state}
      end
    end
  end

  @impl true
  def handle_call({:terminate, simulation_id}, _from, state) do
    case Map.get(state, simulation_id, nil) do
      %{sim_process: p} ->
        RenewCollabSim.Server.SimulationProcess.stop(p)
        {:reply, true, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:exists, simulation_id}, _from, state) do
    {:reply, Map.has_key?(state, simulation_id), state}
  end

  @impl true
  def handle_call({:is_playing, simulation_id}, _from, state) do
    Map.has_key?(state, simulation_id)
    |> case do
      %{sim_process: pid} -> RenewCollabSim.Server.SimulationProcess.is_playing(pid)
      _ -> false
    end
    |> then(&{:reply, &1, state})
  end

  @impl true
  def handle_call(:running_ids, _from, state) do
    {:reply, Map.keys(state), state}
  end

  @impl true
  def handle_call(:count, _from, state) do
    {:reply, map_size(state), state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    for {simulation_id, %{sim_process: ^pid}} <- state do
      # TODO:broadcast
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        "simulation:#{simulation_id}",
        {:simulation_change, simulation_id, :state}
      )

      # TODO:broadcast
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        "simulations",
        {:simulation_change, simulation_id, :state}
      )
    end

    {:noreply,
     Map.filter(state, fn
       {_, %{sim_process: ^pid}} -> false
       _ -> true
     end)}
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
    for {simulation_id, %{sim_process: pid}} <- state do
      RenewCollabSim.Server.SimulationProcess.stop(pid)

      # TODO:broadcast
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        "simulation:#{simulation_id}",
        {:simulation_change, simulation_id, :state}
      )

      # TODO:broadcast
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        "simulations",
        {:simulation_change, simulation_id, :state}
      )
    end
  end
end
