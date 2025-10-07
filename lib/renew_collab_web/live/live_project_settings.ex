defmodule RenewCollabWeb.LiveProjectSettings do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollabProj.Projects

  @topic "project"

  def mount(%{"project_id" => id}, _session, socket) do
    Projects.find_own_project(socket.assigns.current_account, id)
    |> case do
      nil ->
        {:ok, redirect(socket, to: "/")}

      proj ->
        RenewCollabWeb.Endpoint.subscribe(@topic)

        socket =
          socket
          |> assign(:project, proj)
          |> assign(:shadow_net_systems, Projects.find_shadow_net_systems())

        {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} project_id={@project.id} />
      <div style="padding: 1em">
        <.link navigate={~p"/projects"}>Back</.link>
      </div>

      <div style="padding: 1em">
        <h2 style="margin: 0;">Project: {@project.name}</h2>

        <%= if Projects.can_rename(@current_account, @project) do %>
          <h3>Rename Project</h3>

          <form method="post" phx-submit="rename" accept-charset="utf-8">
            <input type="text" name="name" value={@project.name} />
            <button type="submit">Rename</button>
          </form>
        <% end %>

        <h3>Members</h3>
        <%= if  not Enum.empty?(@project.members) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for m <- @project.members do %>
              <%= with acc = %{} <- m.account do %>
                <li>
                  [{m.role}]
                  <%= if Projects.can_remove(@current_account, m) do %>
                    <button type="button" phx-click="remove_member" phx-value-id={m.id}>
                      Remove
                    </button>
                  <% end %>
                  {acc.email}
                </li>
                <% else nil -> %>
                  <li>
                    <button type="button" phx-click="remove_member" phx-value-id={m.id}>
                      Remove
                    </button>
                    [{m.role}] <em>Account deleted</em>
                    (ID: <code>{m.account_id}</code>)
                  </li>
              <% end %>
            <% end %>
          </ul>
        <% else %>
          <p>None</p>
        <% end %>

        <%= if Projects.can_invite(@current_account, @project) do %>
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
            <button type="submit">Invite</button>
          </form>
        <% end %>

        <%= if Projects.can_delete(@current_account, @project) do %>
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
    reload(socket)
  end

  def handle_event("remove_member", %{"id" => member_id}, socket) do
    Projects.remove_member(socket.assigns.project, member_id)
    reload(socket)
  end

  def handle_event("rename", params, socket) do
    Projects.update_project(socket.assigns.project, params)
    reload(socket)
  end

  def handle_event("delete", _params, socket) do
    Projects.delete_project(socket.assigns.project.id)

    {:noreply, redirect(socket, to: "/projects")}
  end

  def reload(socket) do
    {:noreply,
     socket
     |> assign(:project, Projects.find_project(socket.assigns.project.id))
     |> assign(:accounts, Projects.find_accounts())
     |> assign(:documents, Projects.find_documents())
     |> assign(:simulations, Projects.find_simulations())}
  end
end
