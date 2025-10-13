defmodule RenewCollabWeb.ReduxSimulationChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_simulation:" <> simulation_id, _params, socket) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        {:error, %{reason: "not found"}}

      sim ->
        # TODO:subscription
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
           RenewCollabSim.Server.ProjectSimulationServer.exists(
             sim.project_assignment.project_id,
             simulation_id
           ),
           RenewCollabSim.Server.ProjectSimulationServer.is_playing(
             sim.project_assignment.project_id,
             simulation_id
           )
         ), {:project_id, sim.project_assignment.project_id, :simulation_id, simulation_id}}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, simulation_id, {_event, is_playing}},
        _state,
        {:project_id, project_id, :simulation_id, simulation_id}
      ) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        :stop

      sim ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           RenewCollabSim.Server.ProjectSimulationServer.exists(project_id, simulation_id),
           is_playing
         )}
    end
  end

  @impl true
  def handle_message(
        {:simulation_change, simulation_id, _event},
        _state,
        {:project_id, project_id, :simulation_id, simulation_id}
      ) do
    case RenewCollabSim.Simulator.find_simulation_simple(simulation_id) do
      nil ->
        :stop

      sim ->
        {:noreply,
         RenewCollabWeb.SimulationJSON.show_content(
           sim,
           RenewCollabSim.Server.ProjectSimulationServer.exists(project_id, simulation_id),
           false
         )}
    end
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  @impl true
  def handle_event("step", %{}, _state, {:project_id, project_id, :simulation_id, simulation_id}) do
    RenewCollabSim.Server.ProjectSimulationServer.step(project_id, simulation_id)

    :silent
  end

  @impl true
  def handle_event("play", %{}, _state, {:project_id, project_id, :simulation_id, simulation_id}) do
    RenewCollabSim.Server.ProjectSimulationServer.play(project_id, simulation_id)

    :silent
  end

  @impl true
  def handle_event("pause", %{}, _state, {:project_id, project_id, :simulation_id, simulation_id}) do
    RenewCollabSim.Server.ProjectSimulationServer.pause(project_id, simulation_id)

    :silent
  end

  @impl true
  def handle_event(
        "terminate",
        %{},
        _state,
        {:project_id, project_id, :simulation_id, simulation_id}
      ) do
    RenewCollabSim.Server.ProjectSimulationServer.terminate(
      project_id,
      simulation_id
    )

    :silent
  end

  @impl true
  def handle_event("init", %{}, _state, {:project_id, project_id, :simulation_id, simulation_id}) do
    RenewCollabSim.Server.ProjectSimulationServer.setup(project_id, simulation_id)

    :silent
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
