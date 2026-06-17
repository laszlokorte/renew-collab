defmodule RenewCollabWeb.LiveSimulationNetInstanceChannel do
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabSim.Entities
  alias RenewCollabWeb.SimulationError
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  @impl true
  def init("live:net_instance:" <> net_instance_id, _params, socket) do
    %Views.SimulationNetInstance{net_instance_id: net_instance_id}
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      {:error, :access} ->
        {:error, %{reason: "not found"}}

      nil ->
        {:error, %{reason: "not found"}}

      %Entities.SimulationNetInstance{} = net_instance ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{net_instance.simulation_id}")

        {:ok, RenewCollabWeb.SimulationJSON.show_instance_content(net_instance),
         %{
           net_instance_id: net_instance_id,
           simulation_id: net_instance.simulation_id,
           net_instance_label: net_instance.label,
           account: socket.assigns.current_account
         }}
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
      {:error, :access} ->
        :stop

      nil ->
        :stop

      %Entities.SimulationNetInstance{} = instance ->
        {:noreply, RenewCollabWeb.SimulationJSON.show_instance_content(instance)}
    end
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  @impl true
  def handle_event(
        "net_step",
        _payload,
        _state,
        %{
          simulation_id: simulation_id,
          net_instance_label: net_instance_label,
          account: account
        },
        socket
      ) do
    %Actions.SimulationNetStep{
      simulation_id: simulation_id,
      net_instance_label: net_instance_label
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_net_step_failed",
      "Simulation net step could not be performed"
    )
  end

  @impl true
  def handle_event(
        "transition_bindings",
        payload,
        _state,
        %{
          simulation_id: simulation_id,
          net_instance_label: net_instance_label,
          account: account
        },
        socket
      ) do
    transition_id = payload_value(payload, "transition_id")

    result =
      %Actions.SimulationTransitionBindings{
        simulation_id: simulation_id,
        net_instance_label: net_instance_label,
        transition_id: transition_id
      }
      |> perform_action(account)

    case result do
      {:ok,
       %{
         bindings: bindings,
         transition_id: result_transition_id,
         transition_instance: transition_instance
       }} ->
        {:reply,
         %{
           transition_id: result_transition_id,
           transition_instance: transition_instance,
           bindings: bindings
         }, socket}

      {:error, reason} ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: "transition_bindings_failed",
          message: "Transition bindings could not be loaded",
          detail: detail
        })

        {:reply, %{transition_id: transition_id, bindings: [], error: detail}, socket}

      reason ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: "transition_bindings_failed",
          message: "Transition bindings could not be loaded",
          detail: detail
        })

        {:reply, %{transition_id: transition_id, bindings: [], error: detail}, socket}
    end
  end

  @impl true
  def handle_event(
        "fire_transition",
        payload,
        _state,
        %{
          simulation_id: simulation_id,
          net_instance_label: net_instance_label,
          account: account
        },
        socket
      ) do
    result =
      %Actions.SimulationFireTransition{
        simulation_id: simulation_id,
        net_instance_label: net_instance_label,
        transition_id: payload_value(payload, "transition_id"),
        binding_index: payload_value(payload, "binding_index"),
        sync: true
      }
      |> perform_action(account)

    case result do
      :ok ->
        {:reply, %{fired: true}, socket}

      {:ok, _} ->
        {:reply, %{fired: true}, socket}

      {:error, reason} ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: "fire_transition_failed",
          message: "Transition could not be fired",
          detail: detail
        })

        {:reply, %{fired: false, error: detail}, socket}

      reason ->
        detail = simulation_error_detail(reason)

        push_error(socket, %{
          error: "fire_transition_failed",
          message: "Transition could not be fired",
          detail: detail
        })

        {:reply, %{fired: false, error: detail}, socket}
    end
  end

  defp perform_simulation_action(action, account, socket, error, message) do
    action
    |> perform_action(account)
    |> handle_simulation_result(socket, error, message)
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

  defp handle_simulation_result(result, socket, error, message) do
    case result do
      :ok ->
        :ack

      {:ok, _} ->
        :ack

      true ->
        :ack

      false ->
        push_simulation_error(socket, error, message, "The simulation is not running.")

      {:error, reason} ->
        push_simulation_error(socket, error, message, simulation_error_detail(reason))

      reason ->
        push_simulation_error(socket, error, message, simulation_error_detail(reason))
    end
  end

  defp push_simulation_error(socket, error, message, detail) do
    push_error(socket, %{
      error: error,
      message: message,
      detail: detail
    })

    :ack
  end

  defp simulation_error_detail(reason), do: SimulationError.detail(reason)

  defp payload_value(payload, key) when is_map(payload) do
    Map.get(payload, key) || Map.get(payload, String.to_existing_atom(key))
  rescue
    ArgumentError -> Map.get(payload, key)
  end

  defp payload_value(_payload, _key), do: nil
end
