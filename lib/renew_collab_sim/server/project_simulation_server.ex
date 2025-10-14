defmodule RenewCollabSim.Server.ProjectSimulationServer do
  alias RenewCollabSim.Server.SimulationServer
  use GenServer

  def start_link(_defaults) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def setup(project_id, simulation_id) do
    GenServer.cast(__MODULE__, {:setup, project_id, simulation_id})
  end

  def setup_and_wait(project_id, simulation_id) do
    Task.async(fn ->
      GenServer.call(__MODULE__, {:setup, project_id, simulation_id})
    end)
    |> Task.await()
  end

  def step(project_id, simulation_id) do
    GenServer.cast(__MODULE__, {:step, project_id, simulation_id})
  end

  def play(project_id, simulation_id) do
    GenServer.cast(__MODULE__, {:play, project_id, simulation_id})
  end

  def pause(project_id, simulation_id) do
    GenServer.cast(__MODULE__, {:pause, project_id, simulation_id})
  end

  def stop(project_id, simulation_id) do
    GenServer.call(__MODULE__, {:stop, project_id, simulation_id})
  end

  def exists(project_id, simulation_id) do
    GenServer.call(__MODULE__, {:exists, project_id, simulation_id})
  end

  def is_playing(project_id, simulation_id) do
    GenServer.call(__MODULE__, {:is_playing, project_id, simulation_id})
  end

  def running_ids(project_id) do
    GenServer.call(__MODULE__, {:running_ids, project_id})
  end

  def count(project_id) do
    GenServer.call(__MODULE__, {:count, project_id})
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
  def handle_cast({:setup, project_id, simulation_id}, state) do
    Map.get(state, project_id)
    |> case do
      nil ->
        with {:ok, pid} <- RenewCollabSim.Server.SimulationServer.start_monitor(project_id) do
          RenewCollabSim.Server.SimulationServer.setup(pid, simulation_id)

          {:noreply,
           Map.put(state, project_id, %{
             server_process: pid
           })}
        else
          _ ->
            {:reply, :error, state}
        end

      %{server_process: pid} ->
        RenewCollabSim.Server.SimulationServer.setup(pid, simulation_id)
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:step, project_id, simulation_id}, state) do
    case Map.get(state, project_id, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.step(p, simulation_id)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:play, project_id, simulation_id}, state) do
    case Map.get(state, project_id, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.play(p, simulation_id)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:pause, project_id, simulation_id}, state) do
    case Map.get(state, project_id, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.pause(p, simulation_id)
        {:noreply, state}

      nil ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:setup, project_id, simulation_id}, _from, state) do
    Map.get(state, project_id)
    |> case do
      nil ->
        with {:ok, pid} <- RenewCollabSim.Server.SimulationServer.start_monitor(project_id) do
          RenewCollabSim.Server.SimulationServer.setup_and_wait(pid, simulation_id)

          {:reply, :ok,
           Map.put(state, project_id, %{
             server_process: pid
           })}
        else
          _ ->
            {:reply, :error, state}
        end

      %{server_process: pid} ->
        RenewCollabSim.Server.SimulationServer.setup_and_wait(pid, simulation_id)
        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call({:stop, project_id, simulation_id}, _from, state) do
    case Map.get(state, project_id, nil) do
      %{server_process: p} ->
        RenewCollabSim.Server.SimulationServer.stop(p, simulation_id)
        {:reply, true, state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:exists, project_id, simulation_id}, _from, state) do
    case Map.get(state, project_id, nil) do
      %{server_process: p} ->
        {:reply, RenewCollabSim.Server.SimulationServer.exists(p, simulation_id), state}

      nil ->
        {:reply, false, state}
    end
  end

  @impl true
  def handle_call({:is_playing, project_id, simulation_id}, _from, state) do
    Map.has_key?(state, project_id)
    |> case do
      %{server_process: pid} ->
        RenewCollabSim.Server.SimulationServer.is_playing(pid, simulation_id)

      _ ->
        false
    end
    |> then(&{:reply, &1, state})
  end

  @impl true
  def handle_call({:running_ids, project_id}, _from, state) do
    case Map.get(state, project_id, nil) do
      %{server_process: p} ->
        {:reply, RenewCollabSim.Server.SimulationServer.running_ids(p), state}

      nil ->
        {:reply, MapSet.new(), state}
    end
  end

  @impl true
  def handle_call({:count, project_id}, _from, state) do
    case Map.get(state, project_id, nil) do
      %{server_process: p} ->
        {:reply, RenewCollabSim.Server.SimulationServer.count(p), state}

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
    for {_project_id, %{server_process: pid}} <- state do
      RenewCollabSim.Server.SimulationServer.stop_all(pid)
    end
  end
end
