defmodule RenewCollabWeb.LiveProject do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollabProj.Projects

  @topic "project"

  def mount(%{"id" => id}, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)

    socket =
      socket
      |> assign(:project, Projects.find_project(id))
      |> assign(:accounts, Projects.find_accounts())
      |> assign(:documents, Projects.find_documents())
      |> assign(:simulations, Projects.find_simulations())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header />
      <div style="padding: 1em">
        <.link navigate={~p"/projects"}>Back</.link>
      </div>

      <div style="padding: 1em">
        <h2 style="margin: 0;">Project: {@project.name}</h2>

        <h3>Rename Project</h3>

        <form method="post" phx-submit="rename" accept-charset="utf-8">
          <input type="text" name="name" value={@project.name} />
          <button type="submit">Rename</button>
        </form>

        <h3>Members</h3>
        <%= if  not Enum.empty?(@project.members) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for m <- @project.members do %>
              <%= with acc = %{} <- m.account do %>
                <li>
                  <button type="button" phx-click="remove_member" phx-value-id={m.id}>Remove</button> {acc.email}
                </li>
                <% else nil -> %>
                  <li>
                    <button type="button" phx-click="remove_member" phx-value-id={m.id}>
                      Remove
                    </button>
                    <em>Account deleted</em>
                    (ID: <code>{m.account_id}</code>)
                  </li>
              <% end %>
            <% end %>
          </ul>
        <% else %>
          <p>None</p>
        <% end %>

        <form method="post" phx-submit="add_member" accept-charset="utf-8">
          <select name="account_id">
            <option value="">---</option>
            <%= for a <- @accounts do %>
              <option value={a.id} disabled={@project.members |> Enum.any?(&(&1.account_id == a.id))}>
                {a.email}
              </option>
            <% end %>
          </select>
          <button type="submit">Add</button>
        </form>

        <h3>Documents</h3>
        <%= if  not Enum.empty?(@project.documents) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for d <- @project.documents do %>
              <%= with doc = %{} <- d.document do %>
                <li>
                  <button type="button" phx-click="remove_document" phx-value-id={d.id}>
                    Remove
                  </button>
                  {doc.name}
                </li>
                <% else nil -> %>
                  <li>
                    <button type="button" phx-click="remove_document" phx-value-id={d.id}>
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
          <select name="document_id">
            <option value="">---</option>
            <%= for d <- @documents do %>
              <option value={d.id} disabled={d.project_assignment != nil}>{d.name}</option>
            <% end %>
          </select>
          <button type="submit">Add</button>
        </form>

        <h3>Simulations</h3>
        <%= if  not Enum.empty?(@project.simulations) do %>
          <ul style="list-style: none; padding: 0; margin: 0">
            <%= for s <- @project.simulations do %>
              <%= with sim = %{} <- s.simulation do %>
                <li>
                  <button type="button" phx-click="remove_simulation" phx-value-id={s.id}>
                    Remove
                  </button>
                  {sim.id}
                </li>
                <% else nil -> %>
                  <li>
                    <button type="button" phx-click="remove_simulation" phx-value-id={s.id}>
                      Remove
                    </button>
                    <em>Simulation deleted</em>
                    (ID: <code>{s.document_id}</code>)
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
          <button type="submit">Add</button>
        </form>

        <h3>Delete Project</h3>

        <form method="post" phx-submit="delete" accept-charset="utf-8">
          <button type="submit">Delete</button>
        </form>
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
    reload(socket)
  end

  def handle_event("remove_member", %{"id" => member_id}, socket) do
    Projects.remove_member(socket.assigns.project, member_id)
    reload(socket)
  end

  def handle_event("add_document", %{"document_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_document", params, socket) do
    Projects.add_document(socket.assigns.project, params)
    reload(socket)
  end

  def handle_event("remove_document", %{"id" => proj_document_id}, socket) do
    Projects.remove_document(socket.assigns.project, proj_document_id)
    reload(socket)
  end

  def handle_event("add_simulation", %{"simulation_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_simulation", params, socket) do
    Projects.add_simulation(socket.assigns.project, params)
    reload(socket)
  end

  def handle_event("remove_simulation", %{"id" => proj_simulation_id}, socket) do
    Projects.remove_simulation(socket.assigns.project, proj_simulation_id)
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
