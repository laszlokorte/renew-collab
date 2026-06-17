defmodule RenewCollabWeb.LiveSimulationNetInstanceBindingsChannel do
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabSim.Entities
  alias RenewCollabWeb.SimulationError
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("live:net_instance_bindings:" <> params, _payload, socket) do
    with [net_instance_id, transition_id] <- String.split(params, ":", parts: 2),
         %Entities.SimulationNetInstance{} = net_instance <-
           fetch_net_instance(net_instance_id, socket.assigns.current_account) do
      Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{net_instance.simulation_id}")

      scope = %{
        account: socket.assigns.current_account,
        net_instance_id: net_instance_id,
        net_instance_label: net_instance.label,
        simulation_id: net_instance.simulation_id,
        transition_id: transition_id
      }

      {:ok, bindings_state(scope), scope}
    else
      {:error, :access} -> {:error, %{reason: "not found"}}
      nil -> {:error, %{reason: "not found"}}
      _ -> {:error, %{reason: "invalid topic"}}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {simulation_id, _event}},
        _state,
        %{simulation_id: simulation_id} = scope
      ) do
    {:noreply, bindings_state(scope)}
  end

  @impl true
  def handle_message(
        {:simulation_change, simulation_id},
        _state,
        %{simulation_id: simulation_id} = scope
      ) do
    {:noreply, bindings_state(scope)}
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  @impl true
  def handle_event("refresh", _payload, _state, scope) do
    {:reply, %{refreshed: true}, bindings_state(scope)}
  end

  defp fetch_net_instance(net_instance_id, account) do
    %Views.SimulationNetInstance{net_instance_id: net_instance_id}
    |> Fetcher.fetch_as(account)
  end

  defp bindings_state(%{
         account: account,
         simulation_id: simulation_id,
         net_instance_label: net_instance_label,
         transition_id: transition_id
       }) do
    %Actions.SimulationTransitionBindings{
      simulation_id: simulation_id,
      net_instance_label: net_instance_label,
      transition_id: transition_id
    }
    |> perform_action(account)
    |> case do
      {:ok,
       %{
         bindings: bindings,
         transition_id: result_transition_id,
         transition_instance: transition_instance
       }} ->
        %{
          transition_id: result_transition_id,
          transition_instance: transition_instance,
          bindings: bindings,
          error: nil
        }

      false ->
        %{
          transition_id: transition_id,
          transition_instance: nil,
          bindings: [],
          error: "The simulation is not running."
        }

      {:error, reason} ->
        error_state(transition_id, reason)

      reason ->
        error_state(transition_id, reason)
    end
  end

  defp error_state(transition_id, reason) do
    %{
      transition_id: transition_id,
      transition_instance: nil,
      bindings: [],
      error: SimulationError.detail(reason)
    }
  end

  defp perform_action(action, account) do
    try do
      Dispatcher.perform_as(action, account)
    rescue
      exception -> {:error, exception}
    catch
      :exit, reason -> {:error, reason}
      kind, reason -> {:error, {kind, reason}}
    end
  end
end
