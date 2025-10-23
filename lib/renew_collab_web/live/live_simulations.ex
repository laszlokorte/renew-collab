defmodule RenewCollabWeb.LiveSimulations do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  def mount(%{"project_id" => project_id}, _session, socket) do
    RenewCollabProj.Projects.find_project(project_id)
    |> case do
      nil ->
        {:ok, socket |> put_flash(:error, "Project not found") |> redirect(to: ~p"/projects")}

      project ->
        # TODO:subscription
        RenewCollabWeb.Endpoint.subscribe("projects/#{project.id}/simulations")

        socket =
          socket
          |> assign(
            :running,
            RenewCollabSim.Server.ProjectSimulationServer.running_ids(project.id) |> MapSet.new()
          )
          |> assign(
            :project,
            project
          )
          |> assign(
            :sim_form,
            to_form(%{"documents" => [], "formalism" => nil, "main_net" => nil})
          )
          |> assign(
            :simulations,
            %Views.ProjectSimulationsList{
              project_id: project_id
            }
            |> Fetcher.fetch_as(socket.assigns.current_account)
          )
          |> assign(
            :documents,
            %Views.ProjectDocumentsList{
              project_id: project.id
            }
            |> Fetcher.fetch_as(socket.assigns.current_account)
          )

        {:ok, socket}
    end
  end

  def handle_info(:any, socket) do
    {:noreply,
     socket
     |> assign(
       :simulations,
       %Views.ProjectSimulationsList{
         project_id: socket.assigns.project_id
       }
       |> Fetcher.fetch_as(socket.assigns.current_account)
     )
     |> assign(
       :running,
       RenewCollabSim.Server.ProjectSimulationServer.running_ids(socket.assigns.project.id)
       |> MapSet.new()
     )}
  end

  def handle_info({:simulation_change, _, _}, socket) do
    {:noreply,
     socket
     |> assign(
       :simulations,
       %Views.ProjectSimulationsList{
         project_id: socket.assigns.project_id
       }
       |> Fetcher.fetch_as(socket.assigns.current_account)
     )
     |> assign(
       :running,
       RenewCollabSim.Server.ProjectSimulationServer.running_ids(socket.assigns.project.id)
       |> MapSet.new()
     )}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
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

              <th style="border-bottom: 1px solid #333;" align="left" width="100%">Timestep</th>

              <th style="border-bottom: 1px solid #333;" align="right" colspan="5">Actions</th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@simulations) do %>
              <tr>
                <td colspan="7">
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
                      <.link navigate={~p"/simulation/#{sim.id}"}>
                        {sim.label || sim.id}
                      </.link>
                      <%= if sim.label do %>
                        <br /><small>{sim.id}</small>
                      <% end %>
                    </div>
                  </td>

                  <td>
                    {sim.timestep}
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
    RenewCollabSim.Simulator.create_simulation_from_documents(
      socket.assigns.project,
      formalism,
      documents,
      main_net
    )
    |> case do
      %RenewCollabSim.Entites.Simulation{} ->
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
    RenewCollabSim.Simulator.delete_simulation(simulation_id)

    {:noreply, socket |> put_flash(:info, "Simulation deleted")}
  end

  def handle_event("setup", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.setup_and_wait(
      socket.assigns.project.id,
      simulation_id
    )

    {:noreply,
     socket
     |> assign(
       :running,
       RenewCollabSim.Server.ProjectSimulationServer.running_ids(socket.assigns.project.id)
       |> MapSet.new()
     )}
  end

  def handle_event("stop", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.stop(
      socket.assigns.project.id,
      simulation_id
    )

    {:noreply, socket}
  end

  def handle_event("step", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.step(socket.assigns.project.id, simulation_id)

    {:noreply, socket}
  end

  def handle_event("play", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.play(socket.assigns.project.id, simulation_id)

    {:noreply, socket}
  end

  def handle_event("pause", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.pause(socket.assigns.project.id, simulation_id)

    {:noreply, socket}
  end
end
