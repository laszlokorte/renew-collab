defmodule RenewCollabSim.Server.SimulationProcess do
  use GenServer

  def start_monitor(simulation_id) do
    with {:ok, pid} <- GenServer.start(__MODULE__, %{simulation_id: simulation_id}) do
      dbg(pid)
      Process.monitor(pid)
      {:ok, pid}
    else
      e -> e
    end
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  @impl true
  def init(%{simulation_id: simulation_id}) do
    try do
      RenewCollabSim.Simulator.find_simulation(simulation_id)
      schedule_work()
      {:ok, %{simulation_id: simulation_id}}
    rescue
      _ ->
        :ignore
    end
  end

  @impl true
  def handle_info(:work, state = %{simulation_id: simulation_id}) do
    schedule_work()

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
  def handle_call(:stop, _from, state = %{simulation_id: simulation_id}) do
    {:stop, :normal, :shutdown_ok, state}
  end

  defp schedule_work do
    # We schedule the work to happen in 2 hours (written in milliseconds).
    # Alternatively, one might write :timer.hours(2)
    Process.send_after(self(), :work, 2 * 1000)
  end
end
