defmodule RenewCollabWeb.ReduxDocumentChannel do
  use LiveState.Channel, web_module: RenewCollabWeb

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

        Presence.track(socket, account_id, %{
          online_at: inspect(System.system_time(:second)),
          username: username,
          color: make_color(account_id)
        })

        push(socket, "presence_state", Presence.list(socket))

        {:ok, RenewCollabWeb.DocumentJSON.show_content(doc)}
    end
  end

  @impl true
  def handle_message({:document_changed, document_id}, state) do
    {:noreply,
     RenewCollabWeb.DocumentJSON.show_content(
       RenewCollab.Renew.get_document_with_elements(document_id)
     )}
  end

  def handle_in("delete_document", %{"id" => document_id}, socket) do
    {:noreply, socket}
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
