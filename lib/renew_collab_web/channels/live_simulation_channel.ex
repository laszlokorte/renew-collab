defmodule RenewCollabWeb.LiveSimulationChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.Presence

  @impl true
  def init("live:simulation:" <> simulation_id, _params, socket) do
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
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  @impl true
  def handle_event("step", %{}, _state, %{
        simulation_id: simulation_id,
        account: account
      }) do
    %Actions.SimulationStep{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event("play", %{}, _state, %{
        simulation_id: simulation_id,
        account: account
      }) do
    %Actions.SimulationPlay{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event("pause", %{}, _state, %{
        simulation_id: simulation_id,
        account: account
      }) do
    %Actions.SimulationPause{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event(
        "terminate",
        %{},
        _state,
        %{simulation_id: simulation_id, account: account}
      ) do
    %Actions.SimulationTerminate{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  @impl true
  def handle_event("init", %{}, _state, %{
        simulation_id: simulation_id,
        account: account
      }) do
    %Actions.SimulationInitialize{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(account)

    :silent
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
