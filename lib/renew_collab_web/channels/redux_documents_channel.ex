defmodule RenewCollabWeb.ReduxDocumentsChannel do
  use RenewCollabWeb.StateChannel, :redux

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
  def handle_message(:any, _state) do
    {:noreply,
     RenewCollabWeb.DocumentJSON.index_content(%{documents: RenewCollab.Renew.list_documents()})}
  end

  @impl true
  def handle_event("delete_document", %{"id" => document_id}, state) do
    RenewCollab.Commands.DeleteDocument.new(%{
      document_id: document_id
    })
    |> RenewCollab.Commander.run_document_command(false)

    {:noreply, state}
  end

  @impl true
  def handle_event("duplicate_document", %{"id" => document_id}, state) do
    RenewCollab.Commands.DuplicateDocument.new(%{
      document_id: document_id
    })
    |> RenewCollab.Commander.run_document_command()

    {:noreply, state}
  end

  @impl true
  def handle_event("rename_document", %{"id" => document_id, "name" => name}, _state) do
    RenewCollab.Commands.UpdateDocumentMeta.new(%{
      document_id: document_id,
      meta: %{name: name}
    })
    |> RenewCollab.Commander.run_document_command()

    :ack
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
