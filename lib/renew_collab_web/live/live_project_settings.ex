defmodule RenewCollabWeb.LiveProjectSettings do
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

  alias RenewCollabProj.Projects

  @topic "project"

  def mount(%{"project_id" => project_id}, _session, socket) do
    account = socket.assigns.current_account

    %Views.MyProject{
      account_id: account.id,
      project_id: project_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        {:ok, socket |> put_flash(:error, "Project not found") |> redirect(to: ~p"/projects")}

      proj ->
        # TODO:subscription
        RenewCollabWeb.Endpoint.subscribe(@topic)

        socket =
          socket
          |> assign(:project, proj)
          |> assign(
            :members,
            %Views.ProjectMembersList{
              project_id: project_id
            }
            |> Fetcher.fetch_as(account)
          )

        {:ok, socket}
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
              <%= with acc = %{} <- m.account do %>
                <li>
                  <%= if WriteAccess.can(@current_account, %ProjectRemoveMemberAsUser{project_id: @project.id, account_id: acc.id}) do %>
                    <button
                      type="button"
                      phx-click="remove_member"
                      style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      phx-value-id={m.id}
                    >
                      Remove
                    </button>
                  <% end %>
                  <span style="background: #333; color: #fff; font-family: monospace; display: inline-block; padding: 0.5ex;border-radius: 3px">
                    [{m.role}]
                  </span>
                  {acc.email}
                </li>
                <% else nil -> %>
                  <li>
                    <button type="button" phx-click="remove_member" phx-value-id={m.id}>
                      Remove
                    </button>
                    <span style="background: #333; color: #fff; font-family: monospace; display: inline-block; padding: 0.5ex;border-radius: 3px">
                      [{m.role}]
                    </span>
                    <em>Account deleted</em>
                    (ID: <code>{m.account_id}</code>)
                  </li>
              <% end %>
            <% end %>
          </ul>
        <% else %>
          <p>None</p>
        <% end %>

        <%= if WriteAccess.can(@current_account, %Actions.ProjectAddMemberAsUser{project_id: @project.id}) do %>
          <h3>Invite Member</h3>
          <form method="post" phx-submit="add_member" accept-charset="utf-8">
            <label>
              E-Mail: <input type="email" name="account_email" />
            </label>
            <select name="role">
              <%= for r <- RenewCollabProj.Projects.member_roles(@current_account, @project) do %>
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

  def handle_info(:any, socket) do
    socket |> reload()
  end

  def handle_event("add_member", %{"account_email" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_member", params, socket) do
    Projects.add_member(socket.assigns.project, params)
    reload(socket |> put_flash(:info, "Project member invited"))
  end

  def handle_event("remove_member", %{"id" => member_id}, socket) do
    Projects.remove_member(socket.assigns.project, member_id)
    reload(socket |> put_flash(:info, "Project member removed"))
  end

  def handle_event("rename", params, socket) do
    Projects.update_project(socket.assigns.project, params)
    reload(socket |> put_flash(:info, "Project name changed"))
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

  def reload(socket) do
    {:noreply,
     socket
     |> assign(:project, Projects.find_project(socket.assigns.project.id))}
  end
end
