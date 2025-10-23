defmodule RenewCollabWeb.ReduxDocumentsChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabWeb.Presence
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  @impl true
  def init("redux_documents", _params, socket) do
    # TODO:subscription
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "documents")

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

    {:ok, load_state(socket.assigns.current_account, nil),
     %{:project_id => nil, :account => socket.assigns.current_account}}
  end

  defp load_state(current_account, project_id) do
    %Views.ProjectDocumentsList{
      project_id: project_id
    }
    |> Fetcher.fetch_as(current_account)
    |> RenewCollabWeb.ProjectDocumentJSON.index_content()
  end

  @impl true
  def handle_message(:any, _state, %{:project_id => project_id, :account => account}) do
    {:noreply, load_state(account, project_id)}
  end

  @impl true
  def handle_message(_, state, _scope) do
    {:noreply, state}
  end

  @impl true
  def handle_event("delete_document", %{"id" => document_id}, state, _scope) do
    RenewCollab.Renew.delete_document(document_id)

    {:noreply, state}
  end

  @impl true
  def handle_event("duplicate_document", %{"id" => document_id}, state, _scope) do
    RenewCollab.Renew.duplicate_document(document_id)

    {:noreply, state}
  end

  @impl true
  def handle_event("rename_document", %{"id" => document_id, "name" => name}, _state, _scope) do
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
