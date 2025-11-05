defmodule RenewCollabWeb.LiveProjects do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.WriteAccess
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Views
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollabCtrl.Fetcher

  def mount(_params, _session, socket) do
    socket =
      socket |> assign(load_data(socket.assigns.current_account))

    {:ok, socket}
  end

  def load_data(account) do
    %{
      projects: %Views.MyProjectsList{account_id: account.id} |> Fetcher.fetch_as(account),
      invitations:
        %Views.MyProjectInvitations{account_id: account.id} |> Fetcher.fetch_as(account),
      create_form:
        to_form(%{
          "name" => ""
        })
    }
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} />

      <div style="padding: 1em">
        Projects
        <h2 style="margin: 0; display: flex; gap: 1ex; align-items: center;">
          <img class="icon" src="/assets/icon-project.svg" /> Projects
        </h2>
      </div>
      <div style="padding:  0 1em ; display: flex; align-items: start; gap: 1em">
        <fieldset style="width: 30%">
          <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
            New Project
          </legend>

          <.form for={@create_form} phx-submit="create_project" phx-change="validate_project">
            <div style="display: flex; align-items: stretch; gap: 0.1em; flex-direction: column;">
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
        <%= if not Enum.empty?(@invitations)  do %>
          <h2>Invitations</h2>

          <table style="width: 100%;" cellpadding="5">
            <thead>
              <tr>
                <th style="border-bottom: 1px solid #333;" align="left" width="1000">Project</th>
                <th style="border-bottom: 1px solid #333;" align="left" width="100">Role</th>
                <th style="border-bottom: 1px solid #333;" align="left" width="100">Invited at</th>
                <th style="border-bottom: 1px solid #333;" align="left" width="100">Actions</th>
              </tr>
            </thead>
            <tbody>
              <%= for {inv, di} <- @invitations|> Enum.with_index do %>
                <tr {if(rem(di, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td align="left" width="1000">
                    {inv.project.name}
                  </td>
                  <td align="left" width="100">{inv.role}</td>
                  <td>
                    <RenewCollabWeb.RenewComponents.timestamp value={inv.inserted_at} />
                  </td>
                  <td align="left" width="100">
                    <button
                      type="button"
                      phx-click="accept_invitation"
                      phx-value-invitation_id={inv.id}
                      phx-value-project_id={inv.project_id}
                      style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                    >
                      Accept
                    </button>
                    <button
                      type="button"
                      phx-click="reject_invitation"
                      phx-value-invitation_id={inv.id}
                      phx-value-project_id={inv.project_id}
                      style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                    >
                      Reject
                    </button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% end %>

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="1000">Name</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="10">Documents</th>
              <th style="border-bottom: 1px solid #333;" align="left" width="10">
                Shadow Nets Systems
              </th>
              <th style="border-bottom: 1px solid #333;" align="left" width="10">Simulations</th>
              <th style="border-bottom: 1px solid #333;" align="left" width="10">Owners/Members</th>

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
                <td colspan="9">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Projects yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {project, di} <- @projects |> Enum.with_index do %>
                <tr {if(rem(di, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <.link
                      style="color: #078;display: flex; align-items: center; gap: 1ex; justify-content: start;"
                      navigate={~p"/project/#{project.id}/documents"}
                    >
                      <img class="icon" src="/assets/icon-project.svg" />
                      {project.name}
                    </.link>
                  </td>

                  <td width="50">
                    <.link
                      style="color: #078; display: flex; align-items: center; gap: 1ex; justify-content: center;"
                      navigate={~p"/project/#{project.id}/documents"}
                    >
                      <img class="icon" src="/assets/icon-document.svg" />
                      {project.documents |> Enum.count()}
                    </.link>
                  </td>
                  <td width="50">
                    <.link
                      style="color: #078; display: flex; align-items: center; gap: 1ex; justify-content: center;"
                      navigate={~p"/project/#{project.id}/shadow_nets"}
                    >
                      <img class="icon" src="/assets/icon-network.svg" />
                      {project.shadow_net_systems |> Enum.count()}
                    </.link>
                  </td>
                  <td width="50">
                    <.link
                      style="color: #078; display: flex; align-items: center; gap: 1ex; justify-content: center;"
                      navigate={~p"/project/#{project.id}/simulations"}
                    >
                      <img class="icon" src="/assets/icon-simulation.svg" />
                      {project.simulations |> Enum.count()}
                    </.link>
                  </td>

                  <td width="50">
                    <.link
                      style="color: #078; display: flex; align-items: center; gap: 1ex; justify-content: center;"
                      navigate={~p"/project/#{project.id}/settings"}
                    >
                      <img class="icon" src="/assets/icon-gear.svg" />
                      {project.ownerships |> Enum.count()} / {project.members |> Enum.count()}
                    </.link>
                  </td>

                  <td>
                    <RenewCollabWeb.RenewComponents.timestamp value={project.inserted_at} />
                  </td>

                  <td>
                    <RenewCollabWeb.RenewComponents.timestamp value={project.updated_at} />
                  </td>
                  <td width="50">
                    <a target="_blank" href={~p"/projects/#{project.id}/export"}>
                      <button style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff">
                        Export
                      </button>
                    </a>
                  </td>
                  <td width="50">
                    <%= if WriteAccess.can(@current_account, %Actions.ProjectDuplicateAsUser{project_id: project.id}) do %>
                      <button
                        type="button"
                        phx-click="duplicate_project"
                        phx-value-id={project.id}
                        style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                      >
                        Duplicate
                      </button>
                    <% end %>
                  </td>

                  <td width="50">
                    <%= if WriteAccess.can(@current_account, %Actions.ProjectDelete{project_id: project.id}) do %>
                      <button
                        type="button"
                        phx-click="delete_project"
                        phx-value-id={project.id}
                        style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      >
                        Delete
                      </button>
                    <% end %>
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

  def handle_event("create_project", %{"name" => name}, socket) do
    %Actions.ProjectCreateAsUser{
      project_name: name,
      account_id: socket.assigns.current_account.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, %RenewCollabProj.Entities.Project{}} ->
        socket
        |> put_flash(:info, "Project created")
        |> assign(create_form: to_form(%{}))
        |> reload()

      _ ->
        {:noreply,
         socket
         |> put_flash(:info, "Project creation failed")}
    end
  end

  def handle_event("validate_project", params, socket) do
    {:noreply, assign(socket, create_form: to_form(params))}
  end

  def handle_event("delete_project", %{"id" => project_id}, socket) do
    %Actions.ProjectDelete{
      project_id: project_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Project deleted")
        |> assign(create_form: to_form(%{}))
        |> reload()

      _ ->
        {:noreply,
         socket
         |> put_flash(:info, "Project deletion failed")}
    end

    socket
    |> put_flash(:info, "Project deleted")
    |> reload()
  end

  def handle_event(
        "accept_invitation",
        %{"project_id" => project_id, "invitation_id" => invitation_id},
        socket
      ) do
    %Actions.ProjectAcceptInvitation{
      invitation_id: invitation_id,
      project_id: project_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Invitation accepted")
        |> reload()

      _ ->
        socket
        |> put_flash(:info, "Accepting invitation failed")
        |> reload()
    end
  end

  def handle_event(
        "reject_invitation",
        %{"project_id" => project_id, "invitation_id" => invitation_id},
        socket
      ) do
    %Actions.ProjectRejectInvitation{
      invitation_id: invitation_id,
      project_id: project_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Invitation rejected")
        |> reload()

      _ ->
        socket
        |> put_flash(:info, "Rejecting invitation failed")
        |> reload()
    end
  end

  def handle_event("duplicate_project", %{"id" => project_id}, socket) do
    %Actions.ProjectDuplicateAsUser{
      project_id: project_id,
      account_id: socket.assigns.current_account.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Project duplicated")
        |> reload()

      _ ->
        socket
        |> put_flash(:info, "Project duplication failed")
        |> reload()
    end
  end

  def handle_info(:any, socket) do
    socket |> reload()
  end

  def reload(socket) do
    {:noreply, socket |> assign(load_data(socket.assigns.current_account))}
  end
end
