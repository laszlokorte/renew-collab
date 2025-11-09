defmodule RenewCollabWeb.LiveSimulationNetInstanceChannel do
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("live:net_instance:" <> net_instance_id, _params, socket) do
    %Views.SimulationNetInstance{net_instance_id: net_instance_id}
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      nil ->
        {:error, %{reason: "not found"}}

      net_instance ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{net_instance.simulation_id}")

        {:ok, RenewCollabWeb.SimulationJSON.show_instance_content(net_instance),
         %{net_instance_id: net_instance_id, account: socket.assigns.current_account}}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {_simulation_id, _details}},
        _state,
        %{net_instance_id: net_instance_id, account: account}
      ) do
    %Views.SimulationNetInstance{net_instance_id: net_instance_id}
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        :stop

      instance ->
        {:noreply, RenewCollabWeb.SimulationJSON.show_instance_content(instance)}
    end
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end
end
