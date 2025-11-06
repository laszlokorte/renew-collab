defmodule RenewCollabWeb.ReduxDocumentsChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.Presence
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  @impl true
  def init("project-documents:" <> project_id, _params, socket) do
    account_id = socket.assigns.current_account.id
    username = socket.assigns.current_account.username
    connection_id = socket.assigns.connection_id

    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "pub-project-documents:#{project_id}")

    Presence.track(socket, account_id, %{
      online_at: inspect(System.system_time(:second)),
      username: username,
      connection_id: connection_id,
      color: make_color(account_id)
    })

    push(socket, "presence_state", Presence.list(socket))

    {:ok, load_state(socket.assigns.current_account, project_id),
     %{:project_id => project_id, :account => socket.assigns.current_account}}
  end

  defp load_state(current_account, project_id) do
    %Views.ProjectDocumentsList{
      project_id: project_id
    }
    |> Fetcher.fetch_as(current_account)
    |> then(&%{documents: &1})
    |> RenewCollabWeb.ProjectDocumentJSON.index_content()
  end

  @impl true
  def handle_message(:documents_changed, _state, %{:project_id => project_id, :account => account}) do
    {:noreply, load_state(account, project_id)}
  end

  @impl true
  def handle_message(_, state, %{account: _account}) do
    {:noreply, state}
  end

  @impl true
  def handle_event("delete_document", %{"id" => document_id}, state, %{account: account}) do
    %Actions.DocumentDeleteAsUser{
      document_id: document_id
    }
    |> Dispatcher.perform_as(account)

    {:noreply, state}
  end

  @impl true
  def handle_event("duplicate_document", %{"id" => document_id}, state, %{
        account: account,
        project_id: project_id
      }) do
    %Actions.DocumentDuplicateInProject{
      document_id: document_id,
      project_id: project_id
    }
    |> Dispatcher.perform_as(account)

    {:noreply, state}
  end

  @impl true
  def handle_event("rename_document", %{"id" => document_id, "name" => name}, _state, %{
        account: account
      }) do
    %Actions.DocumentUpdateMeta{
      document_id: document_id,
      meta: %{name: name}
    }
    |> Dispatcher.perform_as(account)

    :ack
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
