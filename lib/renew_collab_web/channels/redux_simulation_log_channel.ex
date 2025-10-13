defmodule RenewCollabWeb.ReduxSimulationLogChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("redux_simulation_log:" <> simulation_id, _params, _socket) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        {:error, %{reason: "not found"}}

      sim ->
        # TODO:subscription
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{sim.id}")

        {:ok,
         RenewCollabSim.Simulator.find_simulation_log_entries(simulation_id)
         |> RenewCollabWeb.SimulationJSON.show_log_content(), {:simulation_id, simulation_id}}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, simulation_id, _event},
        _state,
        {:simulation_id, simulation_id}
      ) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        :stop

      sim ->
        {:noreply,
         RenewCollabSim.Simulator.find_simulation_log_entries(sim.id)
         |> RenewCollabWeb.SimulationJSON.show_log_content()}
    end
  end
end
