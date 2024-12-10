defmodule RenewCollabWeb.ReduxSimulationsChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("redux_simulations", _params, _socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulations")

    {:ok,
     RenewCollabWeb.SimulationJSON.index_content(%{
       simulations: RenewCollabSim.Simulator.find_all_simulations(),
       runnings: RenewCollabSim.Server.SimulationServer.running_ids() |> MapSet.new()
     })}
  end

  @impl true
  def handle_message({:simulation_change, _simulation_id, _}, _state) do
    {:noreply,
     RenewCollabWeb.SimulationJSON.index_content(%{
       simulations: RenewCollabSim.Simulator.find_all_simulations(),
       runnings: RenewCollabSim.Server.SimulationServer.running_ids() |> MapSet.new()
     })}
  end

  @impl true
  def handle_event("step", %{"id" => id}, _state, _socket) do
    RenewCollabSim.Server.SimulationServer.step(id)

    :silent
  end

  @impl true
  def handle_event("stop", %{"id" => id}, _state, _socket) do
    RenewCollabSim.Server.SimulationServer.terminate(id)

    :silent
  end

  @impl true
  def handle_event("start", %{"id" => id}, _state, _socket) do
    RenewCollabSim.Server.SimulationServer.setup(id)

    :silent
  end

  @impl true
  def handle_event("delete", %{"id" => id}, _state, _socket) do
    RenewCollabSim.Simulator.delete_simulation(id)
    RenewCollabSim.Server.SimulationServer.terminate(id)

    :silent
  end
end
