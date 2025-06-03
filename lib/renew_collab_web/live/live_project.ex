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

        <h3>Members</h3>
        <ul>
          <%= for m <- @project.members do %>
            <li>{m.account.email}</li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_info(:any, socket) do
    socket |> reload()
  end

  def reload(socket) do
    {:noreply, socket |> assign(:project, Projects.find_project(socket.assigns.project.id))}
  end
end
