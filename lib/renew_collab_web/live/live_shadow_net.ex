defmodule RenewCollabWeb.LiveShadowNet do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabProj.Entities.ProjectShadowNetSystem
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  use RenewCollabCtrl.Helper,
    shadow_net_system:
      {Views.ShadowNetSystem, [:shadow_net_system_id], :shadow_net_system_modified},
    documents: {Views.ProjectDocumentsList, [:project_id], :documents_changed},
    simulations:
      {Views.ShadowNetSystemSimulations, [:shadow_net_system_id], :simulations_changed},
    running: {Views.ProjectRunningSimulationIds, [:project_id], :simulation_change}

  def load_param(:shadow_net_system_id, socket), do: socket.assigns.shadow_net_system_id
  def load_param(:account_id, socket), do: socket.assigns.current_account.id

  def load_param(:project_id, socket),
    do: socket.assigns.shadow_net_system.project_assignment.project_id

  def mount(%{"id" => shadow_net_system_id}, _session, socket) do
    socket
    |> assign(:shadow_net_system_id, shadow_net_system_id)
    |> assign(
      :sim_form,
      to_form(%{"documents" => [], "formalism" => nil, "main_net" => nil})
    )
    |> load_data(true)
    |> case do
      {:error, socket} ->
        {:ok, socket |> put_flash(:error, "Project not found") |> redirect(to: ~p"/projects")}

      {:ok, socket} ->
        project_id = load_param(:project_id, socket)
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "pub-project-simulations:#{project_id}")

        socket
        |> assign(:rename_form, to_form(%{"name" => socket.assigns.shadow_net_system.label}))
        |> then(&{:ok, &1})
    end
  end

  def handle_info(
        {:simulation_change, {_sim_id, _change}},
        %{assigns: %{current_account: account}} = socket
      ) do
    socket
    |> assign(
      simulations:
        %Views.ShadowNetSystemSimulations{
          shadow_net_system_id: load_param(:shadow_net_system_id, socket)
        }
        |> Fetcher.fetch_as(account)
    )
    |> then(&{:noreply, &1})
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header
        flash={@flash}
        tab={:sns}
        project_id={@shadow_net_system.project_assignment.project_id}
      />

      <div style="padding: 1em">
        <.link navigate={~p"/projects"}>
          Projects
        </.link>
        <%= case @shadow_net_system.project_assignment do %>
          <% %ProjectShadowNetSystem{project_id: project_id} -> %>
            /
            <.link navigate={~p"/project/#{project_id}/shadow_nets"} style="color: inherit">
              Shadow Net Systems
            </.link>
          <% _ -> %>
        <% end %>
        / Simulations
        <h2 style="margin: 0; display: flex; gap: 1ex; align-items: center;">
          <img class="icon" src="/assets/icon-network.svg" />
          <span>
            Shadow Net System {@shadow_net_system.label || "Untitled"}<br />
            (<small><code>{@shadow_net_system.id}</code></small>)
          </span>
        </h2>
      </div>

      <div style="padding: 1em">
        <div style="padding: 1em 1em 0; display: flex; align-items: start; gap: 1em">
          <fieldset style="margin-bottom: 1em">
            <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
              Nets
            </legend>
            <dl style="display: grid; grid-template-columns: auto 1fr;">
              <dt>Main Net Name</dt>

              <dd>
                <code>{@shadow_net_system.main_net_name}</code>
              </dd>
              <dt>
                <label>
                  Change main net:
                </label>
              </dt>
              <dd>
                <form phx-change="change_main_net">
                  <select name="main_net">
                    <option></option>
                    <%= for net <- @shadow_net_system.nets do %>
                      <option selected={net.name == @shadow_net_system.main_net_name}>
                        {net.name}
                      </option>
                    <% end %>
                  </select>
                </form>
              </dd>

              <dt>Net Definitions</dt>

              <dd>
                <ul style="list-style: none; margin: 0; padding: 0;">
                  <%= for net <- @shadow_net_system.nets do %>
                    <li>
                      <%= if net.thumbnail_json do %>
                        has thumbnail
                      <% end %>
                      <%= if net.document_json do %>
                        <details>
                          <summary>
                            <button name="shadow_net_id" phx-click="clear_net_document" value={net.id}>
                              X
                            </button>
                            <code>{net.name}</code>
                          </summary>

                          <div style="width: 10em; height: 5em;">
                            <textarea
                              readonly
                              style="position: absolute; z-index:10;white-space: pre-wrap;  overflow-y: auto;"
                            ><%= net.document_json %></textarea>
                          </div>
                        </details>
                      <% else %>
                        <form style="display: inline;" phx-change="change_net_document">
                          <input type="hidden" name="shadow_net_id" value={net.id} />
                          <label>
                            <code>{net.name}</code>
                            <select name="document_id">
                              <option>Assign Document</option>

                              <%= for doc <- @documents do %>
                                <option value={doc.id}>
                                  {doc.name}
                                </option>
                              <% end %>
                            </select>
                          </label>
                        </form>
                      <% end %>
                    </li>
                  <% end %>
                </ul>
              </dd>
            </dl>
          </fieldset>
          <fieldset style="margin-bottom: 1em">
            <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
              Rename
            </legend>

            <.form for={@rename_form} phx-submit="rename" phx-change="validate-rename">
              <div style="display: flex; align-items: stretch; gap: 0.1em">
                <input
                  type="text"
                  name="name"
                  placeholder="Untitled"
                  value={@rename_form[:name].value}
                  id={@rename_form[:name].id}
                />
                <button
                  type="submit"
                  style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff; padding: 1ex"
                >
                  Rename
                </button>
              </div>
            </.form>
          </fieldset>
        </div>
        <div>
          <button
            type="button"
            phx-click="new-simulation"
            style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            New Simulation
          </button>

          <a
            style="color: #078"
            href={~p"/shadow_net/#{@shadow_net_system.id}/binary"}
            target="_blank"
          >
            <button
              type="button"
              style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
            >
              Download SNS File
            </button>
          </a>
        </div>

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="100%">Simulations</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="100%">Created at</th>
              <th style="border-bottom: 1px solid #333;" align="left" width="100%">Timestep</th>

              <th style="border-bottom: 1px solid #333;" align="right" colspan="6">Actions</th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@simulations) do %>
              <tr>
                <td colspan="9">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    <p>
                      No Simulations created yet.
                    </p>

                    <button
                      type="button"
                      phx-click="new-simulation"
                      style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                    >
                      New Simulation
                    </button>
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {sim,si} <- @simulations |> Enum.with_index do %>
                <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <div style="display: flex; align-items: center; gap: 1ex; justify-content: start;">
                      <img class="icon" src="/assets/icon-simulation.svg" />
                      <span>
                        <%= if sim.label do %>
                          <.link navigate={~p"/simulation/#{sim.id}"}>
                            {sim.label}
                          </.link>
                          <br /><small><code>{sim.id}</code></small>
                        <% else %>
                          <.link navigate={~p"/simulation/#{sim.id}"}>
                            <code>{sim.id}</code>
                          </.link>
                        <% end %>
                      </span>
                    </div>
                  </td>

                  <td>
                    <RenewCollabWeb.RenewComponents.timestamp value={sim.inserted_at} />
                  </td>
                  <td>
                    {sim.timestep}
                  </td>

                  <td>
                    <button
                      type="button"
                      phx-click="duplicate"
                      phx-value-simulation_id={sim.id}
                      style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                    >
                      Duplicate
                    </button>
                  </td>
                  <%= if MapSet.member?(@running, sim.id) do %>
                    <td>
                      <button
                        type="button"
                        phx-click="play"
                        phx-value-id={sim.id}
                        style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
                      >
                        Play
                      </button>
                    </td>
                    <td>
                      <button
                        type="button"
                        phx-click="pause"
                        phx-value-id={sim.id}
                        style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
                      >
                        Pause
                      </button>
                    </td>
                    <td>
                      <button
                        type="button"
                        phx-click="step"
                        phx-value-id={sim.id}
                        style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
                      >
                        Step
                      </button>

                      <td>
                        <button
                          type="button"
                          phx-click="stop"
                          phx-value-id={sim.id}
                          style="cursor: pointer; padding: 1ex; border: none; background: #a3a; color: #fff"
                        >
                          Terminate
                        </button>
                      </td>
                    </td>
                  <% else %>
                    <td colspan="4" align="right">
                      <button
                        type="button"
                        phx-click="setup"
                        phx-value-id={sim.id}
                        phx-disable-with="Starting..."
                        style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                      >
                        Setup
                      </button>
                    </td>
                  <% end %>

                  <td>
                    <button
                      type="button"
                      phx-click="delete"
                      phx-value-id={sim.id}
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

  def handle_event("duplicate", %{"simulation_id" => simulation_id}, socket) do
    %Actions.SimulationDuplicateInProject{
      simulation_id: simulation_id,
      project_id: load_param(:project_id, socket)
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket |> put_flash(:info, "Simulation duplicated")}
  end

  def handle_event("validate-rename", %{"name" => new_name}, socket) do
    {:noreply, socket |> assign(:rename_form, to_form(%{"name" => new_name}))}
  end

  def handle_event("rename", %{"name" => new_name}, socket) do
    %Actions.ShadowNetSystemRename{
      shadow_net_system_id: socket.assigns.shadow_net_system_id,
      new_name: new_name
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket |> put_flash(:info, "Shadow net System renamed")}
  end

  def handle_event("delete", %{"id" => simulation_id}, socket) do
    %Actions.SimulationDeleteAsUser{simulation_id: simulation_id}
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket |> put_flash(:info, "Simulation deleted")}
  end

  def handle_event("setup", %{"id" => simulation_id}, socket) do
    %Actions.SimulationInitialize{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Initializing simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Initializing simulation failed")}
    end
  end

  def handle_event("stop", %{"id" => simulation_id}, socket) do
    %Actions.SimulationTerminate{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Stopping simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Stopping simulation failed")}
    end
  end

  def handle_event("step", %{"id" => simulation_id}, socket) do
    %Actions.SimulationStep{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Stepping simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Stepping simulation failed")}
    end
  end

  def handle_event("play", %{"id" => simulation_id}, socket) do
    %Actions.SimulationPlay{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Playing simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Playing simulation failed")}
    end
  end

  def handle_event("pause", %{"id" => simulation_id}, socket) do
    %Actions.SimulationPause{
      simulation_id: simulation_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Pausing simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Payusing simulation failed")}
    end
  end

  def handle_event("change_main_net", %{"main_net" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("change_main_net", %{"main_net" => main_net}, socket) do
    %Actions.ShadowNetSystemSetMainNet{
      shadow_net_system_id: socket.assigns.shadow_net_system_id,
      main_net_name: main_net
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "clear_net_document",
        %{"value" => shadow_net_id},
        socket
      ) do
    %Actions.ShadowNetSystemSetNetDocument{
      shadow_net_system_id: socket.assigns.shadow_net_system_id,
      net_id: shadow_net_id,
      document_id: nil
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "change_net_document",
        %{"shadow_net_id" => shadow_net_id, "document_id" => document_id},
        socket
      ) do
    %Actions.ShadowNetSystemSetNetDocument{
      shadow_net_system_id: socket.assigns.shadow_net_system_id,
      net_id: shadow_net_id,
      document_id: document_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event("new-simulation", %{}, socket) do
    %Actions.SimulationCreateFromShadowNetSystemInProject{
      project_id: load_param(:project_id, socket),
      shadow_net_system_id: socket.assigns.shadow_net_system.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Simulated created")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Creating Simulation failed")}
    end
  end
end
