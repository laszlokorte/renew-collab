defmodule RenewCollabWeb.LiveProjectSettings do
  alias RenewCollabCtrl.Actions.ProjectMemberWithdraw
  alias RenewCollabCtrl.Actions.ProjectRevokeInvitation
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions.ProjectRemoveMemberAsUser
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Actions.ProjectDelete
  alias RenewCollabCtrl.Actions.ProjectRename
  alias RenewCollabCtrl.WriteAccess
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  use RenewCollabCtrl.Helper,
    project: {Views.MyProject, [:account_id, :project_id], :project_changed},
    members: {Views.ProjectMembersList, [:project_id], :project_changed},
    invitations: {Views.ProjectInvitations, [:project_id], :invitations_changed}

  def load_param(:account_id, socket), do: socket.assigns.current_account.id
  def load_param(:project_id, socket), do: socket.assigns.project_id

  def mount(%{"project_id" => project_id}, _session, socket) do
    socket
    |> assign(create_form: to_form(%{}))
    |> assign(:project_id, project_id)
    |> load_data(true)
    |> case do
      {:error, socket} ->
        {:ok, socket |> put_flash(:error, "Project not found") |> redirect(to: ~p"/projects")}

      ok ->
        ok
    end
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header
        tab={:settings}
        flash={@flash}
        project_id={@project.id}
      />

      <div style="padding: 1em">
        <.link navigate={~p"/projects"}>
          Projects
        </.link>
        / Settings
        <h2 style="margin: 0; display: flex; gap: 1ex; align-items: center;">
          <img class="icon" src="/assets/icon-gear.svg" />
          <span>
            Settings (Name: {@project.name}) <br /><small>{@project.id}</small>
          </span>
        </h2>
      </div>

      <div style="padding: 0 1em">
        <%= if WriteAccess.can(@current_account, %ProjectRename{project_id: @project.id}) do %>
          <h3>Project Name</h3>

          <form method="post" phx-submit="rename" accept-charset="utf-8">
            <input type="text" name="name" value={@project.name} />
            <button
              type="submit"
              style="cursor: pointer; padding: 1ex; border: none; background: #3aa; color: #fff"
            >
              Rename
            </button>
          </form>
        <% end %>

        <h3>Project Members</h3>
        <%= if  not Enum.empty?(@project.members) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for m <- @members do %>
              <li>
                <%= if WriteAccess.can(@current_account, %ProjectRemoveMemberAsUser{project_id: @project.id, member_id: m.id}) do %>
                  <button
                    type="button"
                    phx-click="remove_member"
                    style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                    phx-value-id={m.id}
                  >
                    Remove
                  </button>
                <% end %>
                <%= with acc = %{} <- m.account do %>
                  <span style="background: #333; color: #fff; font-family: monospace; display: inline-block; padding: 0.5ex;border-radius: 3px">
                    [{m.role}]
                  </span>
                  {acc.email}
                  <% else nil -> %>
                    <span style="background: #333; color: #fff; font-family: monospace; display: inline-block; padding: 0.5ex;border-radius: 3px">
                      [{m.role}]
                    </span>
                    <em>Account deleted</em>
                    (ID: <code>{m.account_id}</code>)
                <% end %>
              </li>
            <% end %>
          </ul>
        <% else %>
          <p>None</p>
        <% end %>

        <h3>Open invitations</h3>
        <%= if  not Enum.empty?(@invitations) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for i <- @invitations do %>
              <li>
                <%= if WriteAccess.can(@current_account, %ProjectRevokeInvitation{project_id: @project.id, invitation_id: i.id}) do %>
                  <button
                    style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                    type="button"
                    phx-click="revoke_invitation"
                    phx-value-id={i.id}
                  >
                    Revoke
                  </button>
                <% end %>
                <span style="background: #333; color: #fff; font-family: monospace; display: inline-block; padding: 0.5ex;border-radius: 3px">
                  [{i.role}]
                </span>
                {i.email}
              </li>
            <% end %>
          </ul>
        <% else %>
          None
        <% end %>
        <%= if WriteAccess.can(@current_account, %Actions.ProjectInviteMember{project_id: @project.id}) do %>
          <h3>Invite Member</h3>
          <form method="post" phx-submit="invite_member" accept-charset="utf-8">
            <label>
              E-Mail: <input type="email" name="account_email" />
            </label>
            <select name="role">
              <%= for r <- [:editor, :reader] do %>
                <option value={r}>
                  {r}
                </option>
              <% end %>
            </select>
            <button
              type="submit"
              style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
            >
              Invite
            </button>
          </form>
        <% end %>
        <%= if WriteAccess.can(@current_account, %ProjectMemberWithdraw{project_id: @project.id, account_id: @current_account.id}) do %>
          <h3>Leave Project</h3>

          <form method="post" phx-submit="withdraw" accept-charset="utf-8">
            <button
              type="submit"
              style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
            >
              Leave project
            </button>
          </form>
        <% end %>
        <%= if WriteAccess.can(@current_account, %ProjectDelete{project_id: @project.id}) do %>
          <h3>Delete Project</h3>

          <form method="post" phx-submit="delete" accept-charset="utf-8">
            <button
              type="submit"
              style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
            >
              Delete
            </button>
          </form>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("invite_member", %{"account_email" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("invite_member", %{"account_email" => email, "role" => role}, socket) do
    %Actions.ProjectInviteMember{
      project_id: socket.assigns.project.id,
      email: email,
      role: RenewCollabProj.Entities.ProjectMember.parse_role(role)
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Member added to project") |> then(&{:noreply, &1})

      {:error, _} ->
        socket |> put_flash(:error, "Adding member failed") |> then(&{:noreply, &1})
    end
  end

  def handle_event("remove_member", %{"id" => member_id}, socket) do
    %Actions.ProjectRemoveMemberAsUser{
      project_id: socket.assigns.project.id,
      member_id: member_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Member removed") |> then(&{:noreply, &1})

      {:error, _} ->
        socket |> put_flash(:error, "Removing member failed") |> then(&{:noreply, &1})
    end
  end

  def handle_event("revoke_invitation", %{"id" => invitation_id}, socket) do
    %Actions.ProjectRevokeInvitation{
      project_id: socket.assigns.project.id,
      invitation_id: invitation_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Inviation revoked") |> then(&{:noreply, &1})

      {:error, _} ->
        socket |> put_flash(:error, "Revoking inviation failed") |> then(&{:noreply, &1})
    end
  end

  def handle_event("rename", %{"name" => name}, socket) do
    %Actions.ProjectRename{project_id: socket.assigns.project.id, new_name: name}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Project name changed") |> then(&{:noreply, &1})

      _ ->
        socket |> put_flash(:error, "Project rename failed") |> then(&{:noreply, &1})
    end
  end

  def handle_event("withdraw", _params, socket) do
    %Actions.ProjectMemberWithdraw{
      project_id: socket.assigns.project.id,
      account_id: socket.assigns.current_account.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Project left") |> redirect(to: "/projects")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Leaving project failed")}
    end
  end

  def handle_event("delete", _params, socket) do
    %Actions.ProjectDelete{project_id: socket.assigns.project.id}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Project deleted") |> redirect(to: "/projects")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Deleting project failed")}
    end
  end
end
