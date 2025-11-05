defmodule RenewCollabWeb.ReduxProjectChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.Presence
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  @impl true
  def init("project:" <> project_id, _params, socket) do
    # TODO:subscription
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "projects")

    account_id = socket.assigns.current_account.id
    username = socket.assigns.current_account.username
    connection_id = socket.assigns.connection_id

    Presence.track(socket, account_id, %{
      online_at: inspect(System.system_time(:second)),
      username: username,
      connection_id: connection_id,
      color: make_color(account_id)
    })

    push(socket, "presence_state", Presence.list(socket))

    {:ok, load_state(project_id, socket.assigns.current_account),
     %{project_id: project_id, account: socket.assigns.current_account}}
  end

  defp load_state(project_id, current_account) do
    %Views.MyProject{
      project_id: project_id,
      account_id: current_account.id
    }
    |> Fetcher.fetch_as(current_account)
    |> then(&%{project: &1})
    |> RenewCollabWeb.ProjectJSON.show_content()
  end

  @impl true
  def handle_message(:any, _state, %{:project_id => project_id, :account => account}) do
    {:noreply, load_state(project_id, account)}
  end

  @impl true
  def handle_message(_, state, %{account: _account}) do
    {:noreply, state}
  end

  @impl true
  def handle_event("rename_project", %{"name" => name}, _state, %{
        account: account,
        project_id: project_id
      }) do
    %Actions.ProjectRename{
      project_id: project_id,
      new_name: name
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
