defmodule RenewCollabWeb.ReduxSimulationLogChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_simulation_log:" <> simulation_id, _params, socket) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        {:error, %{reason: "not found"}}

      sim ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{simulation_id}")

        {:ok,
         RenewCollabSim.Simulator.find_simulation_log_entries(simulation_id)
         |> RenewCollabWeb.SimulationJSON.show_log_content(),
         assign(socket, :simulation_id, simulation_id)}
    end
  end

  @impl true
  def handle_message({:simulation_change, simulation_id, _event}, _state) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        :stop

      sim ->
        {:noreply,
         RenewCollabSim.Simulator.find_simulation_log_entries(simulation_id)
         |> RenewCollabWeb.SimulationJSON.show_log_content()}
    end
  end
end
