defmodule RenewCollabWeb.LiveSimulationLogChannel do
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabSim.Entities
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("live:simulation_log:" <> simulation_id, _params, socket) do
    %Views.SimulationWithLogEntries{
      simulation_id: simulation_id
    }
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      {:error, :access} ->
        {:error, %{reason: "not found"}}

      nil ->
        {:error, %{reason: "not found"}}

      %Entities.Simulation{} = sim ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{sim.id}")

        {:ok,
         sim.log_entries
         |> RenewCollabWeb.SimulationJSON.show_log_content(),
         %{simulation_id: simulation_id, account: socket.assigns.current_account}}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {simulation_id, _event}},
        _state,
        %{simulation_id: simulation_id, account: account}
      ) do
    %Views.SimulationWithLogEntries{
      simulation_id: simulation_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      {:error, :access} ->
        :stop

      nil ->
        :stop

      %Entities.Simulation{} = sim ->
        {:noreply,
         sim.log_entries
         |> RenewCollabWeb.SimulationJSON.show_log_content()}
    end
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end
end
