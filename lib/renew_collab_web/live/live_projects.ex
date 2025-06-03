defmodule RenewCollabWeb.LiveProjects do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollabProj.Projects

  @topic "projects"

  def mount(_params, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)

    socket =
      socket
      |> assign(:projects, Projects.list_all_projects())
      |> assign(create_form: to_form(%{}))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header />
      <div style="padding: 1em 1em 0; display: flex; align-items: start; gap: 1em">
        <fieldset style="margin-bottom: 1em">
          <p>Create a new Project</p>

          <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
            New Project
          </legend>

          <.form for={@create_form} phx-submit="create_project" phx-change="validate_project">
            <div style="display: flex; align-items: stretch; gap: 0.1em">
              <input
                type="text"
                name="name"
                placeholder="Untitled"
                value={@create_form[:name].value}
                id={@create_form[:name].id}
              />
              <button
                type="submit"
                style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff; padding: 1ex"
              >
                Create Project
              </button>
            </div>
          </.form>
        </fieldset>
      </div>

      <div style="padding: 1em">
        <h2 style="margin: 0;">Projects</h2>

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="1000">Name</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="200">Created</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="200">Last Updated</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="3">
                Actions
              </th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@projects) do %>
              <tr>
                <td colspan="8">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Projects yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {project, di} <- @projects |> Enum.with_index do %>
                <tr {if(rem(di, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <.link style="color: #078" navigate={~p"/project/#{project.id}"}>
                      {project.name}
                    </.link>
                  </td>

                  <td>{project.inserted_at |> Calendar.strftime("%Y-%m-%d %H:%M")}</td>

                  <td>{project.updated_at |> Calendar.strftime("%Y-%m-%d %H:%M")}</td>

                  <td width="50"></td>

                  <td width="50"></td>

                  <td width="50">
                    <button
                      type="button"
                      phx-click="delete_project"
                      phx-value-id={project.id}
                      style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def handle_event("create_project", params, socket) do
    with {:ok, %RenewCollabProj.Entites.Project{}} <-
           Projects.create_project(
             params
             |> Map.update("name", "", fn
               "" -> "untitled"
               n -> n
             end)
           ) do
      socket |> assign(create_form: to_form(%{})) |> reload()
    else
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("validate_project", params, socket) do
    {:noreply, assign(socket, create_form: to_form(params))}
  end

  def handle_event("delete_project", %{"id" => id}, socket) do
    Projects.delete_project(id)

    socket |> reload()
  end

  def handle_info(:any, socket) do
    socket |> reload()
  end

  def reload(socket) do
    {:noreply, socket |> assign(:projects, Projects.list_all_projects())}
  end
end
