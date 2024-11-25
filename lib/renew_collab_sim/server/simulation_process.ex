defmodule RenewCollabSim.Server.SimulationProcess do
  use GenServer

  def start_monitor(simulation_id) do
    with {:ok, pid} <- GenServer.start(__MODULE__, %{simulation_id: simulation_id}) do
      Process.monitor(pid)
      {:ok, pid}
    else
      e -> e
    end
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
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

  @impl true
  def init(%{simulation_id: simulation_id}) do
    try do
      simulation = RenewCollabSim.Simulator.find_simulation(simulation_id)
      {sim_process, directory} = init_process(simulation)

      {:ok, %{simulation_id: simulation_id, sim_process: sim_process, directory: directory}}
    rescue
      _ ->
        :ignore
    end
  end

  @impl true
  def handle_info(:work, state = %{simulation_id: simulation_id}) do
    %RenewCollabSim.Entites.SimulationLogEntry{
      simulation_id: simulation_id,
      content: "foooo"
    }
    |> RenewCollab.Repo.insert()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "simulation:#{simulation_id}",
      :any
    )

    {:noreply, state}
  end

  @impl true
  def handle_call(:stop, _from, state = %{simulation_id: simulation_id, sim_process: sim_process}) do
    %RenewCollabSim.Entites.SimulationLogEntry{
      simulation_id: simulation_id,
      content: "simulation stopped"
    }
    |> RenewCollab.Repo.insert()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "simulation:#{simulation_id}",
      :any
    )

    Process.exit(sim_process, :kill)

    {:stop, :normal, :shutdown_ok, state}
  end

  @impl true
  def handle_cast({:log, {:exit, status}}, state = %{simulation_id: simulation_id}) do
    %RenewCollabSim.Entites.SimulationLogEntry{
      simulation_id: simulation_id,
      content: "exit #{status}"
    }
    |> RenewCollab.Repo.insert()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "simulation:#{simulation_id}",
      :any
    )

    {:stop, :normal, state}
  end

  @impl true
  def handle_cast(:step, state = %{sim_process: sim_process}) do
    send(sim_process, {:command, "simulation step\n"})
    {:noreply, state}
  end

  @impl true
  def handle_cast(:play, state = %{sim_process: sim_process}) do
    send(sim_process, {:command, "simulation run\n"})
    {:noreply, state}
  end

  @impl true
  def handle_cast(:pause, state = %{sim_process: sim_process}) do
    send(sim_process, {:command, "simulation stop\n"})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:log, content}, state = %{simulation_id: simulation_id}) do
    %RenewCollabSim.Entites.SimulationLogEntry{
      simulation_id: simulation_id,
      content: content
    }
    |> RenewCollab.Repo.insert()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "simulation:#{simulation_id}",
      :any
    )

    {:noreply, state}
  end

  @impl true
  # handle termination
  def terminate(reason, state = %{directory: directory, sim_process: sim_process}) do
    Process.exit(sim_process, :kill)
    File.rm_rf(directory)
    dbg(directory)
    state
  end

  defp init_process(simulation) do
    slf = self()

    {:ok, output_root} = Path.safe_relative("#{UUID.uuid4(:default)}", System.tmp_dir!())
    {:ok, sns_path} = Path.safe_relative("compiled.ssn", output_root)
    {:ok, script_path} = Path.safe_relative("compile-script", output_root)

    File.mkdir_p(output_root)

    script_content =
      [
        "startsimulation #{sns_path} #{simulation.shadow_net_system.main_net_name} -i"
      ]
      |> Enum.join("\n")

    File.write!(script_path, script_content)
    File.write!(sns_path, simulation.shadow_net_system.compiled)

    sim_process =
      RenewCollabSim.Script.Runner.start_and_collect(script_path, fn log ->
        dbg("yyyy")

        GenServer.cast(slf, {:log, log})
      end)

    dbg("xxxx")

    {sim_process, output_root}
  end
end
