defmodule RenewCollabSim.Server.SimulationServer do
  use GenServer

  def start_link(_defaults) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def setup(simulation_id) do
    GenServer.cast(__MODULE__, {:setup, simulation_id})
  end

  def step(simulation_id) do
    GenServer.cast(__MODULE__, {:step, simulation_id})
  end

  def stop(simulation_id) do
    GenServer.cast(__MODULE__, {:stop, simulation_id})
  end

  def terminate(simulation_id) do
    GenServer.call(__MODULE__, {:terminate, simulation_id})
  end

  def exists(simulation_id) do
    GenServer.call(__MODULE__, {:exists, simulation_id})
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
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "simulation:#{simulation_id}",
          :state
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
    {:noreply, state}
  end

  @impl true
  def handle_cast({:stop, simulation_id}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_call({:terminate, simulation_id}, _from, state) do
    case Map.get(state, simulation_id, nil) do
      %{sim_process: p} ->
        dbg(p)

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
  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    for {simulation_id, %{sim_process: ^pid}} <- state do
      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        "simulation:#{simulation_id}",
        :state
      )
    end

    {:noreply,
     Map.filter(state, fn
       {k, %{sim_process: ^pid}} -> false
       _ -> true
     end)}
  end

  @impl true
  # handle the trapped exit call
  def handle_info({:EXIT, _from, reason}, state) do
    dbg("aaaaaa")
    cleanup(reason, state)
    # see GenServer docs for other return types
    {:stop, reason, state}
  end

  @impl true
  # handle termination
  def terminate(reason, state) do
    dbg("xxxxxx")
    cleanup(reason, state)
    state
  end

  defp cleanup(reason, state) do
    for {simulation_id, %{sim_process: pid}} <- state do
      RenewCollabSim.Server.SimulationProcess.stop(pid)

      Phoenix.PubSub.broadcast(
        RenewCollab.PubSub,
        "simulation:#{simulation_id}",
        :state
      )
    end
  end
end
