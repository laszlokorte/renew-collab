defmodule RenewCollabWeb.ReduxDocumentsChannel do
  use LiveState.Channel, web_module: RenewCollabWeb

  alias RenewCollabWeb.Presence

  @impl true
  def init("redux_documents", _params, socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "documents")

    account_id = socket.assigns.current_account.account_id
    username = socket.assigns.current_account.username

    Presence.track(socket, account_id, %{
      online_at: inspect(System.system_time(:second)),
      username: username,
      color: make_color(account_id)
    })

    push(socket, "presence_state", Presence.list(socket))

    {:ok,
     RenewCollabWeb.DocumentJSON.index_content(%{documents: RenewCollab.Renew.list_documents()})}
  end

  @impl true
  def handle_message(:any, state) do
    {:noreply,
     RenewCollabWeb.DocumentJSON.index_content(%{documents: RenewCollab.Renew.list_documents()})}
  end

  def handle_event("delete_document", %{"id" => document_id}, socket) do
    RenewCollab.Commands.DeleteDocument.new(%{
      document_id: document_id
    })
    |> RenewCollab.Commander.run_document_command(false)

    {:noreply, socket}
  end

  def handle_event("duplicate_document", %{"id" => document_id}, socket) do
    RenewCollab.Commands.DuplicateDocument.new(%{
      document_id: document_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, socket}
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
