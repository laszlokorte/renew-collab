defmodule RenewCollabWeb.LiveProjectsChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.Presence
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  @impl true
  def init("my-projects", _params, socket) do
    account_id = socket.assigns.current_account.id
    username = socket.assigns.current_account.username
    connection_id = socket.assigns.connection_id

    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "pub-my-projects:#{account_id}")

    Presence.track(socket, account_id, %{
      online_at: inspect(System.system_time(:second)),
      username: username,
      connection_id: connection_id,
      color: make_color(account_id)
    })

    push(socket, "presence_state", Presence.list(socket))

    {:ok, load_state(socket.assigns.current_account),
     %{:account => socket.assigns.current_account}}
  end

  defp load_state(current_account) do
    %Views.MyProjectsList{
      account_id: current_account.id
    }
    |> Fetcher.fetch_as(current_account)
    |> then(&%{projects: &1})
    |> RenewCollabWeb.ProjectJSON.index_content()
  end

  @impl true
  def handle_message(:projects_changed, _state, %{account: account}) do
    {:noreply, load_state(account)}
  end

  @impl true
  def handle_message(_, state, %{account: _account}) do
    {:noreply, state}
  end

  @impl true
  def handle_event("delete_project", %{"id" => project_id}, state, %{account: account}) do
    %Actions.ProjectDelete{
      project_id: project_id
    }
    |> Dispatcher.perform_as(account)

    {:noreply, state}
  end

  @impl true
  def handle_event("duplicate_project", %{"id" => project_id}, state, %{
        account: account
      }) do
    %Actions.ProjectDuplicateAsUser{
      account_id: account.id,
      project_id: project_id
    }
    |> Dispatcher.perform_as(account)

    {:noreply, state}
  end

  @impl true
  def handle_event("rename_project", %{"id" => project_id, "name" => name}, _state, %{
        account: account
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
