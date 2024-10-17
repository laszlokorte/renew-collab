defmodule RenewCollabWeb.ReduxDocumentChannel do
  use RenewCollabWeb.StateChannel, :redux

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_document:" <> document_id, _params, socket) do
    case RenewCollab.Renew.get_document_with_elements(document_id) do
      nil ->
        {:error, %{reason: "not found"}}

      doc ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "document:#{document_id}")

        account_id = socket.assigns.current_account.account_id
        username = socket.assigns.current_account.username
        connection_id = socket.assigns.connection_id

        Presence.track(socket, account_id, %{
          online_at: inspect(System.system_time(:second)),
          username: username,
          connection_id: connection_id,
          color: make_color(account_id),
          cursor: %{x: 0, y: 0}
        })

        push(socket, "presence_state", Presence.list(socket))

        {:ok, RenewCollabWeb.DocumentJSON.show_content(doc)}
    end
  end

  @impl true
  def handle_message({:document_changed, document_id}, _state) do
    {:noreply,
     RenewCollabWeb.DocumentJSON.show_content(
       RenewCollab.Renew.get_document_with_elements(document_id)
     )}
  end

  @impl true
  def handle_event("cursor", %{"x" => x, "y" => y}, _state, socket) do
    account_id = socket.assigns.current_account.account_id
    old_meta = Presence.get_by_key(socket, account_id)

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        cursor: %{x: x, y: y}
      })
    )

    :silent
  end

  @impl true
  def handle_event("select", layer_id, _state, socket) when is_binary(layer_id) do
    account_id = socket.assigns.current_account.account_id
    old_meta = Presence.get_by_key(socket, account_id)

    Presence.update(
      socket,
      account_id,
      &Map.merge(&1, %{
        selection: layer_id
      })
    )

    :silent
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
