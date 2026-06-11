defmodule RenewCollabWeb.LiveSimulationBreakpointsChannel do
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabSim.Entities
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("live:simulation_breakpoints:" <> simulation_id, _params, socket) do
    %Views.SimulationWithState{simulation_id: simulation_id}
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      {:error, :access} ->
        {:error, %{reason: "not found"}}

      nil ->
        {:error, %{reason: "not found"}}

      %Entities.Simulation{} ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{simulation_id}")

        {:ok, breakpoint_state(simulation_id, socket.assigns.current_account),
         %{simulation_id: simulation_id, account: socket.assigns.current_account}}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {simulation_id, _event}},
        _state,
        %{simulation_id: simulation_id, account: account}
      ) do
    {:noreply, breakpoint_state(simulation_id, account)}
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  defp breakpoint_state(simulation_id, account) do
    try do
      %Actions.SimulationListBreakpoints{simulation_id: simulation_id}
      |> Dispatcher.perform_as(account)
      |> case do
        {:ok, breakpoints} when is_list(breakpoints) ->
          %{breakpoints: breakpoints}

        _ ->
          %{breakpoints: []}
      end
    rescue
      _ -> %{breakpoints: []}
    catch
      :exit, _ -> %{breakpoints: []}
      _, _ -> %{breakpoints: []}
    end
  end
end
