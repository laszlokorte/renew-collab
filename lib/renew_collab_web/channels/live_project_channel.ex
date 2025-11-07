defmodule RenewCollabWeb.LiveProjectChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  @impl true
  def init("project:" <> project_id, _params, socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "pub-project:#{project_id}")

    {:ok, load_state(project_id, socket.assigns.current_account),
     %{project_id: project_id, account: socket.assigns.current_account}}
  end

  defp load_state(project_id, current_account) do
    %Views.MyProject{
      project_id: project_id,
      account_id: current_account.id
    }
    |> Fetcher.fetch_as(current_account)
    |> RenewCollabWeb.ProjectJSON.show_content()
  end

  @impl true
  def handle_message(:project_changed, _state, %{:project_id => project_id, :account => account}) do
    {:noreply, load_state(project_id, account)}
  end

  @impl true
  def handle_message(_, state, %{account: _account}) do
    {:noreply, state}
  end

  @impl true
  def handle_event("rename", %{"name" => name}, _state, %{
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

  @impl true
  def handle_event("invite", %{"email" => email, "role" => role}, _state, %{
        account: account,
        project_id: project_id
      }) do
    %Actions.ProjectInviteMember{
      project_id: project_id,
      email: email,
      role: RenewCollabProj.Entities.ProjectMember.parse_role(role)
    }
    |> Dispatcher.perform_as(account)

    :ack
  end

  @impl true
  def handle_event("revoke_invitation", %{"invitation_id" => invitation_id}, _state, %{
        account: account,
        project_id: project_id
      }) do
    %Actions.ProjectRevokeInvitation{
      project_id: project_id,
      invitation_id: invitation_id
    }
    |> Dispatcher.perform_as(account)

    :ack
  end

  @impl true
  def handle_event("remove_member", %{"member_id" => member_id}, _state, %{
        account: account,
        project_id: project_id
      }) do
    %Actions.ProjectRemoveMemberAsUser{
      project_id: project_id,
      member_id: member_id
    }
    |> Dispatcher.perform_as(account)

    :ack
  end
end
