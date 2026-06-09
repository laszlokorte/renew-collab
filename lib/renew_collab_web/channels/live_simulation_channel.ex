defmodule RenewCollabWeb.LiveSimulationChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.Presence
  alias LiveState.Event

  @impl true
  def init("live:simulation:" <> simulation_id, _params, socket) do
    dbg(socket.assigns.current_account)

    %Views.SimulationWithState{simulation_id: simulation_id}
    |> Fetcher.fetch_as(socket.assigns.current_account)
    |> case do
      nil ->
        {:error, %{reason: "not found"}}

      %{} = sim ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{simulation_id}")

        account_id = socket.assigns.current_account.id
        username = socket.assigns.current_account.username
        connection_id = socket.assigns.connection_id

        Presence.track(socket, account_id, %{
          online_at: inspect(System.system_time(:second)),
          username: username,
          connection_id: connection_id,
          color: make_color(account_id),
          cursor: nil
        })

        push(socket, "presence_state", Presence.list(socket))

        {:ok,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           %Views.SimulationIsActive{
             project_id: sim.project_assignment.project_id,
             simulation_id: simulation_id
           }
           |> Fetcher.fetch_as(socket.assigns.current_account),
           %Views.SimulationIsPlaying{
             project_id: sim.project_assignment.project_id,
             simulation_id: simulation_id
           }
           |> Fetcher.fetch_as(socket.assigns.current_account)
         ),
         %{
           project_id: sim.project_assignment.project_id,
           simulation_id: simulation_id,
           account: socket.assigns.current_account
         }}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {simulation_id, {_event, is_playing}}},
        _state,
        %{project_id: project_id, simulation_id: simulation_id, account: account}
      ) do
    %Views.SimulationWithState{simulation_id: simulation_id}
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        :stop

      %{} = sim ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           %Views.SimulationIsActive{
             project_id: project_id,
             simulation_id: simulation_id
           }
           |> Fetcher.fetch_as(account),
           is_playing
         )}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, {simulation_id, _event}},
        _state,
        %{project_id: project_id, simulation_id: simulation_id, account: account}
      ) do
    %Views.SimulationWithState{simulation_id: simulation_id}
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        :stop

      %{} = sim ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           %Views.SimulationIsActive{
             project_id: project_id,
             simulation_id: simulation_id
           }
           |> Fetcher.fetch_as(account),
           false
         )}
    end
  end

  @impl true
  def handle_message(
        {:simulation_error, {simulation_id, error}},
        state,
        %{simulation_id: simulation_id}
      ) do
    {:reply, %Event{name: "error", detail: error}, state}
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  @impl true
  def handle_event("step", _payload, _state, %{
        simulation_id: simulation_id,
        account: account
      }, socket) do
    %Actions.SimulationStep{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_step_failed",
      "Simulation step could not be performed"
    )
  end

  @impl true
  def handle_event("play", _payload, _state, %{
        simulation_id: simulation_id,
        account: account
      }, socket) do
    %Actions.SimulationPlay{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_play_failed",
      "Simulation could not be started"
    )
  end

  @impl true
  def handle_event("pause", _payload, _state, %{
        simulation_id: simulation_id,
        account: account
      }, socket) do
    %Actions.SimulationPause{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_pause_failed",
      "Simulation could not be paused"
    )
  end

  @impl true
  def handle_event(
        "terminate",
        _payload,
        _state,
        %{simulation_id: simulation_id, account: account},
        socket
      ) do
    %Actions.SimulationTerminate{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_terminate_failed",
      "Simulation could not be terminated"
    )
  end

  @impl true
  def handle_event("init", _payload, _state, %{
        simulation_id: simulation_id,
        account: account
      }, socket) do
    %Actions.SimulationInitialize{
      simulation_id: simulation_id
    }
    |> perform_simulation_action(
      account,
      socket,
      "simulation_init_failed",
      "Simulation could not be initialized"
    )
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end

  defp perform_simulation_action(action, account, socket, error, message) do
    try do
      Dispatcher.perform_as(action, account)
    rescue
      exception -> {:error, exception}
    catch
      :exit, reason -> {:error, reason}
      kind, reason -> {:error, {kind, reason}}
    end
    |> handle_simulation_result(socket, error, message)
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

  defp simulation_error_detail(nil), do: nil
  defp simulation_error_detail(:error), do: "The simulation process could not be started."
  defp simulation_error_detail(:ignore), do: "The simulation process could not be started."
  defp simulation_error_detail({:error, reason}), do: simulation_error_detail(reason)
  defp simulation_error_detail({:stop, reason}), do: simulation_error_detail(reason)

  defp simulation_error_detail(%{__exception__: true} = error) do
    Exception.message(error)
  end

  defp simulation_error_detail(reason) when is_binary(reason), do: reason
  defp simulation_error_detail(reason), do: inspect(reason)
end
