defmodule RenewCollabWeb.LiveSimulations do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  use RenewCollabCtrl.Helper,
    project: {Views.MyProject, [:account_id, :project_id], :project_changed},
    documents: {Views.ProjectDocumentsList, [:project_id], :documents_changed},
    simulations: {Views.ProjectSimulationsList, [:project_id], :simulations_changed}

  def load_param(:account_id, socket), do: socket.assigns.current_account.id
  def load_param(:project_id, socket), do: socket.assigns.project_id

  def mount(%{"project_id" => project_id}, _session, socket) do
    socket
    |> assign(:project_id, project_id)
    |> assign(
      :sim_form,
      to_form(%{"documents" => [], "formalism" => nil, "main_net" => nil})
    )
    |> assign(
      running:
        RenewCollabSim.Server.ScopedSimulationServer.running_ids(project_id)
        |> MapSet.new()
    )
    |> load_data(true)
    |> case do
      {:error, socket} ->
        {:ok, socket |> put_flash(:error, "Project not found") |> redirect(to: ~p"/projects")}

      ok ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "projects/#{project_id}/simulations")
        ok
    end
  end

  def handle_info(
        {:simulation_change, _sim_id, _change},
        %{assigns: %{project_id: project_id, current_account: account}} = socket
      ) do
    socket
    |> assign(
      running:
        RenewCollabSim.Server.ScopedSimulationServer.running_ids(project_id)
        |> MapSet.new(),
      simulations:
        %Views.ProjectSimulationsList{project_id: project_id} |> Fetcher.fetch_as(account)
    )
    |> then(&{:noreply, &1})
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header
        flash={@flash}
        tab={:simulations}
        project_id={@project.id}
      />

      <div style="padding: 1em">
        <.link navigate={~p"/projects"}>
          Projects
        </.link>
        / Simulations
        <h2 style="margin: 0; display: flex; gap: 1ex; align-items: center;">
          <img class="icon" src="/assets/icon-simulation.svg" /> Simulations
        </h2>
      </div>

      <div style="padding: 0 1em; display: flex; align-items: start; gap: 1em">
        <fieldset>
          <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
            Simulate Documents
          </legend>
          <form phx-submit="compile" phx-change="validate">
            <div>
              <select multiple name="documents[]" size="8" width="200" style="width:100%">
                <%= for doc <- @documents do %>
                  <option selected={Enum.member?(@sim_form["documents"].value, doc.id)} value={doc.id}>
                    {doc.name}
                  </option>
                <% end %>
              </select>
            </div>
            <div>
              <label>
                Formalism:
                <select name="formalism" style="width: 100%; box-sizing:border-box;">
                  <%= for f <- RenewCollabSim.Compiler.SnsCompiler.formalisms() do %>
                    <option value={f} selected={@sim_form["formalism"].value == f}>{f}</option>
                  <% end %>
                </select>
              </label>
            </div>
            <%= if not Enum.empty?(@sim_form["documents"].value) do %>
              <div>
                <label>
                  Main Name:
                  <select name="main_net" style="width: 100%; box-sizing:border-box;">
                    <%= for doc <- @documents,  Enum.member?(@sim_form["documents"].value, doc.id)do %>
                      <option value={doc.name} selected={doc.name == @sim_form["main_net"].value}>
                        {doc.name}
                      </option>
                    <% end %>
                  </select>
                </label>
              </div>
              <button
                type="submit"
                phx-disable-with="Compiling..."
                style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
              >
                Simulate
              </button>
            <% end %>
          </form>
        </fieldset>
      </div>

      <div style="padding: 1em">
        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="100%">Simulations</th>
              <th style="border-bottom: 1px solid #333;" align="left" width="100%">Created</th>

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
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {sim,si} <- @simulations |> Enum.with_index do %>
                <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <div style="color: #078; display: flex; align-items: center; gap: 1ex; justify-content: start;">
                      <img class="icon" src="/assets/icon-simulation.svg" />
                      <span>
                        <.link navigate={~p"/simulation/#{sim.id}"}>
                          {sim.label || sim.id}
                        </.link>
                        <%= if sim.label do %>
                          <br /><small>{sim.id}</small>
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
      project_id: socket.assigns.project.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket |> put_flash(:info, "Simulation duplicated")}
  end

  def handle_event(
        "validate",
        %{"documents" => documents, "main_net" => main_net, "formalism" => formalism},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       :sim_form,
       to_form(%{"documents" => documents, "formalism" => formalism, "main_net" => main_net})
     )}
  end

  def handle_event(
        "validate",
        %{"documents" => documents, "formalism" => formalism},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       :sim_form,
       to_form(%{
         "documents" => documents,
         "formalism" => formalism,
         "main_net" => documents |> Enum.at(0)
       })
     )}
  end

  def handle_event(
        "compile",
        %{"documents" => documents, "main_net" => main_net, "formalism" => formalism},
        socket
      ) do
    %Actions.SimulationCreateFromDocumentsInProject{
      project_id: socket.assigns.project.id,
      document_ids: documents,
      formalism: formalism,
      main_net_name: main_net
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, %RenewCollabSim.Entities.Simulation{}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Simulation created")
         |> assign(
           :sim_form,
           to_form(%{"documents" => [], "formalism" => nil, "main_net" => nil})
         )}

      {:error, {:dup, _}} ->
        {:noreply, socket |> put_flash(:error, "Duplicate net names")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to create simulation")}
    end
  end

  def handle_event("delete", %{"id" => simulation_id}, socket) do
    %Actions.SimulationDeleteAsUser{simulation_id: simulation_id}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Simulation deleted")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to delete simulation")}
    end
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
end
