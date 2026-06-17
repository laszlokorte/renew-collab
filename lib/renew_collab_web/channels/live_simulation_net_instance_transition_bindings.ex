defmodule RenewCollabWeb.LiveSimulationNetInstanceTransitionBindingsChannel do
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabSim.Entities
  alias RenewCollabWeb.SimulationError
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init(
        <<"live:net_instance_bindings:", net_instance_id::binary-size(36), ":",
          transition_id::binary>>,
        _params,
        socket
      ) do
    %Views.SimulationNetInstance{net_instance_id: net_instance_id}
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      {:error, :access} ->
        {:error, %{reason: "not found"}}

      nil ->
        {:error, %{reason: "not found"}}

      %Entities.SimulationNetInstance{label: net_instance_label, simulation_id: simulation_id} =
          net_instance ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{simulation_id}")

        bindings = query_bindings(socket.assigns.current_account, net_instance, transition_id)

        {:ok, bindings,
         %{
           net_instance: net_instance,
           transition_id: transition_id,
           account: socket.assigns.current_account
         }}

      _ ->
        {:error, %{reason: "not found"}}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {_simulation_id, _details}},
        _state,
        %{net_instance: net_instance, account: account, transition_id: transition_id}
      ) do
    {:noreply, query_bindings(account, net_instance, transition_id)}
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  defp query_bindings(
         account,
         %Entities.SimulationNetInstance{
           label: net_instance_label,
           simulation_id: simulation_id
         },
         transition_id
       ) do
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
         transition_id: ^transition_id
       }} ->
        %{
          bindings:
            bindings
            |> Enum.sort()
        }

      _ ->
        %{bindings: []}
    end
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
