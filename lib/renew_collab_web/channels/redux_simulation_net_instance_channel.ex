defmodule RenewCollabWeb.ReduxSimulationNetInstanceChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("redux_net_instance:" <> net_instance_id, _params, socket) do
    case RenewCollabSim.Simulator.find_simulation_net_instance(net_instance_id) do
      nil ->
        {:error, %{reason: "not found"}}

      net_instance ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{net_instance.simulation_id}")

        {:ok, RenewCollabWeb.SimulationJSON.show_instance_content(net_instance),
         assign(socket, :net_instance_id, net_instance_id)}
    end
  end

  @impl true
  def handle_message({:simulation_change, _simulation_id, _details}, %{id: net_instance_id}) do
    RenewCollabSim.Simulator.find_simulation_net_instance(net_instance_id)
    |> case do
      nil ->
        :stop

      ni ->
        {:noreply, RenewCollabWeb.SimulationJSON.show_instance_content(ni)}
    end
  end

  @impl true
  def handle_message(_, state) do
    {:noreply, state}
  end
end
