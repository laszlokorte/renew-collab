defmodule RenewCollabWeb.ReduxSimulationsChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_simulations", _params, socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulations")

    account_id = socket.assigns.current_account.account_id
    username = socket.assigns.current_account.username
    connection_id = socket.assigns.connection_id

    Presence.track(socket, account_id, %{
      online_at: inspect(System.system_time(:second)),
      username: username,
      connection_id: connection_id,
      color: make_color(account_id)
    })

    push(socket, "presence_state", Presence.list(socket))

    {:ok,
     RenewCollabWeb.SimulationJSON.index_content(%{
       simulations: RenewCollabSim.Simulator.find_all_simulations()
     })}
  end

  @impl true
  def handle_message(:any, _state) do
    {:noreply,
     RenewCollabWeb.SimulationJSON.index_content(%{
       simulations: RenewCollabSim.Simulator.find_all_simulations()
     })}
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
