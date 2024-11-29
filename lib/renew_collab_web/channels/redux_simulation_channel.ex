defmodule RenewCollabWeb.ReduxSimulationChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_simulation:" <> simulation_id, _params, socket) do
    case RenewCollabSim.Simulator.find_simulation(simulation_id) do
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

        {:ok, RenewCollabWeb.SimulationJSON.show_content(sim),
         assign(socket, :simulation_id, simulation_id)}
    end
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
