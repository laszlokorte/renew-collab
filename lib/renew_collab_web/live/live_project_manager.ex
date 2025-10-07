defmodule RenewCollabWeb.LiveProjectManager do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollabProj.Projects

  @topic "project"

  def mount(%{"project_id" => id}, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)

    socket =
      socket
      |> assign(:project, Projects.find_project(id))
      |> assign(:accounts, Projects.find_accounts())
      |> assign(:documents, Projects.find_documents())
      |> assign(:simulations, Projects.find_simulations())
      |> assign(:shadow_net_systems, Projects.find_shadow_net_systems())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} />
      <div style="padding: 1em">
        <.link navigate={~p"/manage/projects"}>Projects Management</.link>
        / Project
        <h2 style="margin: 0; display: flex; align-items: center; gap: 1ex;">
          <img class="icon" src="/assets/icon-project.svg" /> Project: {@project.name}
        </h2>
      </div>

      <div style="padding: 1em">
        <%= if Projects.can_rename(@current_account, @project) do %>
          <h3>Rename Project</h3>

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

        <h3>Members</h3>
        <%= if  not Enum.empty?(@project.members) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for m <- @project.members do %>
              <%= with acc = %{} <- m.account do %>
                <li>
                  <%= if Projects.can_force_remove(@current_account, m) do %>
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
                    <button
                      type="button"
                      phx-click="remove_member"
                      style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      phx-value-id={m.id}
                    >
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

        <%= if Projects.can_invite(@current_account, @project) do %>
          <form method="post" phx-submit="add_member" accept-charset="utf-8">
            <select name="account_id">
              <option value="">---</option>
              <%= for a <- @accounts do %>
                <option
                  value={a.id}
                  disabled={@project.members |> Enum.any?(&(&1.account_id == a.id))}
                >
                  {a.email}
                </option>
              <% end %>
            </select>
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

        <h3>Documents</h3>
        <%= if  not Enum.empty?(@project.documents) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for d <- @project.documents do %>
              <%= with doc = %{} <- d.document do %>
                <li>
                  <button
                    type="button"
                    style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                    phx-click="remove_document"
                    phx-value-id={d.id}
                  >
                    Remove
                  </button>
                  {doc.name}
                  <small>({doc.id})</small>
                </li>
                <% else nil -> %>
                  <li>
                    <button
                      type="button"
                      style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      phx-click="remove_document"
                      phx-value-id={d.id}
                    >
                      Remove
                    </button>
                    <em>Document deleted</em>
                    (ID: <code>{d.document_id}</code>)
                  </li>
              <% end %>
            <% end %>
          </ul>
        <% else %>
          <p>None</p>
        <% end %>

        <form method="post" phx-submit="add_document" accept-charset="utf-8">
          <h4>Unassigned Documents</h4>
          <select name="document_id">
            <option value="">---</option>
            <%= for d <- @documents do %>
              <option value={d.id} disabled={d.project_assignment != nil}>{d.name}({d.id})</option>
            <% end %>
          </select>
          <button
            type="submit"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Assign
          </button>
        </form>
        <h4>All Documents</h4>
        <form method="post" phx-submit="dup_document" accept-charset="utf-8">
          <select name="document_id">
            <option value="">---</option>
            <%= for d <- @documents do %>
              <option value={d.id}>{d.name} ({d.id})</option>
            <% end %>
          </select>
          <button
            type="submit"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Copy into this project
          </button>
        </form>

        <h3>Shadow Net Systems</h3>
        <%= if  not Enum.empty?(@project.shadow_net_systems) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for s <- @project.shadow_net_systems do %>
              <%= with ssn = %{} <- s.shadow_net_system do %>
                <li>
                  <button
                    type="button"
                    style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                    phx-click="remove_ssn"
                    phx-value-id={s.id}
                  >
                    Remove
                  </button>
                  {ssn.label || "Untitled"} <small>({ssn.id})</small>
                </li>
                <% else nil -> %>
                  <li>
                    <button
                      type="button"
                      style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      phx-click="remove_ssn"
                      phx-value-id={s.id}
                    >
                      Remove
                    </button>
                    <em>SSN deleted</em>
                    (ID: <code>{s.shadow_net_system_id}</code>)
                  </li>
              <% end %>
            <% end %>
          </ul>
        <% else %>
          <p>None</p>
        <% end %>

        <form method="post" phx-submit="add_ssn" accept-charset="utf-8">
          <select name="shadow_net_system_id">
            <option value="">---</option>
            <%= for s <- @shadow_net_systems do %>
              <option value={s.id} disabled={s.project_assignment != nil}>{s.id}</option>
            <% end %>
          </select>
          <button
            type="submit"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Assign
          </button>
        </form>

        <h3>Simulations</h3>
        <%= if  not Enum.empty?(@project.simulations) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for s <- @project.simulations do %>
              <%= with sim = %{} <- s.simulation do %>
                <li>
                  <button
                    type="button"
                    style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                    phx-click="remove_simulation"
                    phx-value-id={s.id}
                  >
                    Remove
                  </button>
                  {sim.label || "Untitled"} <small>({sim.id})</small>
                </li>
                <% else nil -> %>
                  <li>
                    <button
                      type="button"
                      style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      phx-click="remove_simulation"
                      phx-value-id={s.id}
                    >
                      Remove
                    </button>
                    <em>Simulation deleted</em>
                    (ID: <code>{s.simulation_id}</code>)
                  </li>
              <% end %>
            <% end %>
          </ul>
        <% else %>
          <p>None</p>
        <% end %>

        <form method="post" phx-submit="add_simulation" accept-charset="utf-8">
          <select name="simulation_id">
            <option value="">---</option>
            <%= for s <- @simulations do %>
              <option value={s.id} disabled={s.project_assignment != nil}>{s.id}</option>
            <% end %>
          </select>
          <button
            type="submit"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Assign
          </button>
        </form>
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

  def handle_event("add_member", %{"account_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_member", params, socket) do
    Projects.add_member(socket.assigns.project, params)
    socket |> put_flash(:info, "Project member added") |> reload
  end

  def handle_event("remove_member", %{"id" => member_id}, socket) do
    Projects.force_remove_member(socket.assigns.project, member_id)
    socket |> put_flash(:info, "Project member removed") |> reload
  end

  def handle_event("add_document", %{"document_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_document", params, socket) do
    Projects.add_document(socket.assigns.project, params)
    socket |> put_flash(:info, "Document added") |> reload
  end

  def handle_event("dup_document", %{"document_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("dup_document", %{"document_id" => document_id}, socket) do
    Projects.duplicate_document_into_project(socket.assigns.project, document_id)
    socket |> put_flash(:info, "Document duplicated") |> reload
  end

  def handle_event("remove_document", %{"id" => proj_document_id}, socket) do
    Projects.remove_document(socket.assigns.project, proj_document_id)
    socket |> put_flash(:info, "Document removed") |> reload
  end

  def handle_event("add_simulation", %{"simulation_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_simulation", params, socket) do
    Projects.add_simulation(socket.assigns.project, params)
    socket |> put_flash(:info, "Simulation added") |> reload
  end

  def handle_event("remove_simulation", %{"id" => proj_simulation_id}, socket) do
    Projects.remove_simulation(socket.assigns.project, proj_simulation_id)
    socket |> put_flash(:info, "Simulation removed") |> reload
  end

  def handle_event("add_ssn", params, socket) do
    Projects.add_shadow_net_system(socket.assigns.project, params)
    socket |> put_flash(:info, "Shadow net system added") |> reload
  end

  def handle_event("remove_ssn", %{"id" => proj_ssn_id}, socket) do
    Projects.remove_shadow_net_system(socket.assigns.project, proj_ssn_id)
    socket |> put_flash(:info, "Shadow net system removed") |> reload
  end

  def handle_event("rename", params, socket) do
    Projects.update_project(socket.assigns.project, params)
    socket |> put_flash(:info, "Project name changed") |> reload
  end

  def handle_event("delete", _params, socket) do
    Projects.delete_project(socket.assigns.project.id)

    {:noreply, socket |> put_flash(:info, "Project deleted") |> redirect(to: "/manage/projects")}
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
