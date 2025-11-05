defmodule RenewCollabWeb.ReduxSimulationLogChannel do
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("redux_simulation_log:" <> simulation_id, _params, socket) do
    %Views.SimulationWithLogEntries{
      simulation_id: simulation_id
    }
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      nil ->
        {:error, %{reason: "not found"}}

      sim ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{sim.id}")

        {:ok,
         sim.log_entries
         |> RenewCollabWeb.SimulationJSON.show_log_content(),
         %{simulation_id: simulation_id, account: socket.assigns.current_account}}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, simulation_id, _event},
        _state,
        %{simulation_id: simulation_id, account: account}
      ) do
    %Views.SimulationWithLogEntries{
      simulation_id: simulation_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        :stop

      sim ->
        {:noreply,
         sim.log_entries
         |> RenewCollabWeb.SimulationJSON.show_log_content()}
    end
  end
end
