defmodule RenewCollabWeb.ReduxSimulationChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_simulation:" <> simulation_id, _params, socket) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        {:error, %{reason: "not found"}}

      sim ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{simulation_id}")

        account_id = socket.assigns.current_account.account_id
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
           RenewCollabSim.Server.SimulationServer.exists(simulation_id),
           RenewCollabSim.Server.SimulationServer.is_playing(simulation_id)
         ), assign(socket, :simulation_id, simulation_id)}
    end
  end

  @impl true
  def handle_message({:simulation_change, simulation_id, {_event, is_playing}}, _state) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        :stop

      sim ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           RenewCollabSim.Server.SimulationServer.exists(simulation_id),
           is_playing
         )}
    end
  end

  @impl true
  def handle_message({:simulation_change, simulation_id, _event}, _state) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        :stop

      sim ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           RenewCollabSim.Server.SimulationServer.exists(simulation_id),
           false
         )}
    end
  end

  @impl true
  def handle_message(_, state) do
    {:noreply, state}
  end

  @impl true
  def handle_event("step", %{}, _state, socket) do
    RenewCollabSim.Server.SimulationServer.step(socket.assigns.simulation_id)

    :silent
  end

  @impl true
  def handle_event("play", %{}, _state, socket) do
    RenewCollabSim.Server.SimulationServer.play(socket.assigns.simulation_id)

    :silent
  end

  @impl true
  def handle_event("pause", %{}, _state, socket) do
    RenewCollabSim.Server.SimulationServer.pause(socket.assigns.simulation_id)

    :silent
  end

  @impl true
  def handle_event("terminate", %{}, _state, socket) do
    RenewCollabSim.Server.SimulationServer.terminate(socket.assigns.simulation_id)

    :silent
  end

  @impl true
  def handle_event("init", %{}, _state, socket) do
    RenewCollabSim.Server.SimulationServer.setup(socket.assigns.simulation_id)

    :silent
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
