defmodule RenewCollabWeb.LiveProjectManager do
  alias RenewCollabCtrl.WriteAccess
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollabProj.Projects

  @topic "project"

  def mount(%{"project_id" => project_id}, _session, socket) do
    account = socket.assigns.current_account

    %Views.GlobalProject{
      project_id: project_id
    }
    |> Fetcher.fetch_as(account)
    |> case do
      nil ->
        socket
        |> put_flash(:error, "Project not found")
        |> redirect(to: ~p"/manage/projects")
        |> then(&{:ok, &1})

      project ->
        # TODO:subscription
        RenewCollabWeb.Endpoint.subscribe(@topic)

        socket
        |> assign(load_data(project, account))
        |> then(&{:ok, &1})
    end
  end

  def load_data(project, account) do
    %{
      project: project,
      accounts:
        %Views.GlobalAccounts{}
        |> Fetcher.fetch_as(account),
      documents:
        %Views.GlobalDocumentsList{}
        |> Fetcher.fetch_as(account),
      simulations:
        %Views.GlobalSimulationsList{}
        |> Fetcher.fetch_as(account),
      shadow_net_systems:
        %Views.GlobalShadowNetSystemsList{}
        |> Fetcher.fetch_as(account),
      assigned_to_project:
        %Views.GlobalProjectAllAssignments{}
        |> Fetcher.fetch_as(account)
    }
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
        <%= if WriteAccess.can(@current_account, %Actions.ProjectRename{project_id: @project.id}) do %>
          <div style="border: 2px dashed #aaa; margin: 1em 0">
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
          </div>
        <% end %>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(40em, 1fr)); gap: 1em;">
          <div style="border: 2px dashed #aaa">
            <h3>Members</h3>
            <%= if  not Enum.empty?(@project.members) do %>
              <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 2px">
                <%= for m <- @project.members do %>
                  <li>
                    <%= if WriteAccess.can(@current_account, %Actions.ProjectRemoveMemberAsAdmin{project_id: @project.id, member_account_id: m.account_id}) do %>
                      <button
                        type="button"
                        phx-click="remove_member"
                        style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                        phx-value-id={m.account_id}
                      >
                        Remove
                      </button>
                    <% end %>
                    <img class="icon" src="/assets/icon-user.svg" style="vertical-align: middle" />
                    <%= case  m.account do %>
                      <% %{id: account_id, email: account_email} -> %>
                        <span style="background: #333; color: #fff; font-family: monospace; display: inline-block; padding: 0.5ex;border-radius: 3px">
                          [{m.role}] {account_email}
                        </span>
                      <% %Ecto.Association.NotLoaded{} -> %>
                        <span style="background: #333; color: #fff; font-family: monospace; display: inline-block; padding: 0.5ex;border-radius: 3px">
                          [{m.role}]
                        </span>
                        <em>Account not loaded</em>
                        (ID: <code>{m.account_id}</code>)
                      <% nil -> %>
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

            <%= if WriteAccess.can(@current_account, %Actions.ProjectAddMemberAsAdmin{project_id: @project.id}) do %>
              <form method="post" phx-submit="add_member" accept-charset="utf-8">
                <select name="account_id">
                  <option value="">---</option>
                  <%= for a <- @accounts do %>
                    <option
                      value={a.id}
                      disabled={Enum.any?(@project.members, &(&1.account_id == a.id))}
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
          </div>
          <div style="border: 2px dashed #aaa">
            <h3>Documents</h3>
            <%= if  not Enum.empty?(@project.documents) do %>
              <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 2px">
                <%= for d <- @project.documents do %>
                  <li>
                    <button
                      type="button"
                      style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      phx-click="remove_document"
                      phx-value-id={d.document_id}
                    >
                      Remove
                    </button>

                    <img class="icon" src="/assets/icon-document.svg" style="vertical-align: middle" />
                    <img
                      class="icon"
                      src={"/documents/#{d.document_id}/thumbnail"}
                      style="vertical-align: middle"
                    />
                    <%= case  d.document do %>
                      <% %{id: doc_id} -> %>
                        <small>({d.document_id})</small>
                      <% %Ecto.Association.NotLoaded{} -> %>
                        <em>Document not loaded</em> (ID: <code>{d.document_id}</code>)
                      <% nil -> %>
                        <em>Document deleted</em> (ID: <code>{d.document_id}</code>)
                    <% end %>
                  </li>
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
                  <option
                    value={d.id}
                    disabled={@assigned_to_project.documents |> MapSet.member?(d.id)}
                  >
                    {d.name}({d.id})
                  </option>
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
          </div>
          <div style="border: 2px dashed #aaa">
            <h3>Shadow Net Systems</h3>
            <%= if  not Enum.empty?(@project.shadow_net_systems) do %>
              <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 2px">
                <%= for s <- @project.shadow_net_systems do %>
                  <li>
                    <button
                      type="button"
                      style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      phx-click="remove_sns"
                      phx-value-id={s.shadow_net_system_id}
                    >
                      Remove
                    </button>
                    <img class="icon" src="/assets/icon-network.svg" style="vertical-align: middle" />
                    <%= case s.shadow_net_system do %>
                      <% %{id: sns_id} -> %>
                        <small>({sns_id})</small>
                      <% %Ecto.Association.NotLoaded{} -> %>
                        <em>Shadow Net System not loaded</em>
                        (ID: <code>{s.shadow_net_system_id}</code>)
                      <% nil -> %>
                        <em>Shadow Net System deleted</em> (ID: <code>{s.shadow_net_system_id}</code>)
                    <% end %>
                  </li>
                <% end %>
              </ul>
            <% else %>
              <p>None</p>
            <% end %>

            <form method="post" phx-submit="add_sns" accept-charset="utf-8">
              <select name="shadow_net_system_id">
                <option value="">---</option>
                <%= for s <- @shadow_net_systems do %>
                  <option
                    value={s.id}
                    disabled={@assigned_to_project.shadow_net_systems |> MapSet.member?(s.id)}
                  >
                    {s.id}
                  </option>
                <% end %>
              </select>
              <button
                type="submit"
                style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
              >
                Assign
              </button>
            </form>
          </div>
          <div style="border: 2px dashed #aaa">
            <h3>Simulations</h3>
            <%= if  not Enum.empty?(@project.simulations) do %>
              <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 2px">
                <%= for s <- @project.simulations do %>
                  <li>
                    <button
                      type="button"
                      style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                      phx-click="remove_simulation"
                      phx-value-id={s.simulation_id}
                    >
                      Remove
                    </button>

                    <img
                      class="icon"
                      src="/assets/icon-simulation.svg"
                      style="vertical-align: middle"
                    />
                    <%= case s.simulation do %>
                      <% %{id: sim_id, label: sim_label} -> %>
                        {sim_label || "Untitled"} <small>({sim_id})</small>
                      <% %Ecto.Association.NotLoaded{} -> %>
                        <em>Simulation not loaded</em> (ID: <code>{s.simulation_id}</code>)
                      <% nil -> %>
                        <em>Simulation deleted</em> (ID: <code>{s.simulation_id}</code>)
                    <% end %>
                  </li>
                <% end %>
              </ul>
            <% else %>
              <p>None</p>
            <% end %>

            <form method="post" phx-submit="add_simulation" accept-charset="utf-8">
              <select name="simulation_id">
                <option value="">---</option>
                <%= for s <- @simulations do %>
                  <option
                    value={s.id}
                    disabled={@assigned_to_project.shadow_net_systems |> MapSet.member?(s.id)}
                  >
                    {s.id}
                  </option>
                <% end %>
              </select>
              <button
                type="submit"
                style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
              >
                Assign
              </button>
            </form>
          </div>
        </div>
        <%= if WriteAccess.can(@current_account, %Actions.ProjectDelete{project_id: @project.id}) do %>
          <hr />
          <h3>Delete Project</h3>

          <form method="post" phx-submit="delete" phx-value-id={@project.id} accept-charset="utf-8">
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

  def handle_event("add_member", %{"account_id" => account_id, "role" => role}, socket) do
    %Actions.ProjectAddMemberAsAdmin{
      project_id: socket.assigns.project.id,
      account_id: account_id,
      role: role
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Project member added") |> reload

      _ ->
        socket |> put_flash(:error, "Adding project member failed") |> reload
    end
  end

  def handle_event("remove_member", %{"id" => account_id}, socket) do
    %Actions.ProjectRemoveMemberAsAdmin{
      project_id: socket.assigns.project.id,
      member_account_id: account_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Member removed from project") |> reload

      _ ->
        socket |> put_flash(:error, "Removing member failed") |> reload
    end
  end

  def handle_event("add_document", %{"document_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_document", %{"document_id" => document_id}, socket) do
    %Actions.ProjectAddDocumentAsAdmin{
      project_id: socket.assigns.project.id,
      document_id: document_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Document assigned to project") |> reload

      _ ->
        socket |> put_flash(:error, "Assigning document failed") |> reload
    end
  end

  def handle_event("dup_document", %{"document_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("dup_document", %{"document_id" => document_id}, socket) do
    %Actions.DocumentDuplicateInProject{
      document_id: document_id,
      project_id: socket.assigns.project.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    socket |> put_flash(:info, "Document duplicated") |> reload
  end

  def handle_event("remove_document", %{"id" => document_id}, socket) do
    %Actions.ProjectRemoveDocumentAsAdmin{
      project_id: socket.assigns.project.id,
      document_id: document_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Document removed from project") |> reload

      _ ->
        socket |> put_flash(:error, "Removing document failed") |> reload
    end
  end

  def handle_event("add_simulation", %{"simulation_id" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("add_simulation", %{"simulation_id" => simulation_id}, socket) do
    %Actions.ProjectAddSimulationAsAdmin{
      project_id: socket.assigns.project.id,
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Simlation assigned to project") |> reload

      _ ->
        socket |> put_flash(:error, "Assigning simulation failed") |> reload
    end
  end

  def handle_event("remove_simulation", %{"id" => simulation_id}, socket) do
    %Actions.ProjectRemoveSimulationAsAdmin{
      project_id: socket.assigns.project.id,
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Simulation removed from project") |> reload

      _ ->
        socket |> put_flash(:error, "Removing Simulation failed") |> reload
    end
  end

  def handle_event("add_sns", %{"shadow_net_system_id" => sns_id}, socket) do
    %Actions.ProjectAddShadowNetSystemAsAdmin{
      project_id: socket.assigns.project.id,
      sns_id: sns_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Shadow Net System assigned to project") |> reload

      _ ->
        socket |> put_flash(:error, "Assigning Shadow Net System failed") |> reload
    end
  end

  def handle_event("remove_sns", %{"id" => sns_id}, socket) do
    %Actions.ProjectRemoveShadowNetSystemAsAdmin{
      project_id: socket.assigns.project.id,
      sns_id: sns_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Shadow Net System removed from project") |> reload

      _ ->
        socket |> put_flash(:error, "Removing Shadow Net System failed") |> reload
    end
  end

  def handle_event("rename", %{"name" => name}, socket) do
    %Actions.ProjectRename{project_id: socket.assigns.project.id, new_name: name}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Project name changed") |> reload

      _ ->
        socket |> put_flash(:error, "Project rename failed") |> reload
    end
  end

  def handle_event("delete", %{"id" => project_id}, socket) do
    %Actions.ProjectDelete{project_id: project_id}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        socket |> put_flash(:info, "Project deleted") |> redirect(to: "/manage/projects")

      _ ->
        {:noreply,
         socket
         |> put_flash(:info, "Project deletion failed")}
    end
    |> then(&{:noreply, &1})
  end

  def reload(socket) do
    {:noreply,
     socket
     |> assign(
       load_data(
         %Views.GlobalProject{
           project_id: socket.assigns.project.id
         }
         |> Fetcher.fetch_as(socket.assigns.current_account),
         socket.assigns.current_account
       )
     )}
  end
end
