defmodule RenewCollabWeb.LiveSimulations do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  def mount(%{"project_id" => project_id}, _session, socket) do
    RenewCollabProj.Projects.list_project_simulations(project_id)
    |> case do
      nil ->
        {:ok, socket |> redirect(to: ~p"/")}

      project ->
        RenewCollabWeb.Endpoint.subscribe("projects/#{project.id}/simulations")

        socket =
          socket
          |> assign(
            :running,
            RenewCollabSim.Server.SimulationServer.running_ids() |> MapSet.new()
          )
          |> assign(
            :project,
            project
          )
          |> assign(
            :simulations,
            RenewCollabSim.Simulator.list_simulations(
              RenewCollabProj.Projects.list_project_simulations(project_id)
            )
          )
          |> assign(
            :documents,
            RenewCollab.Renew.list_documents(
              RenewCollabProj.Projects.list_project_documents(project.id)
            )
          )

        {:ok, socket}
    end
  end

  def handle_info(:any, socket) do
    {:noreply,
     socket
     |> assign(
       :simulations,
       RenewCollabSim.Simulator.list_simulations(
         RenewCollabProj.Projects.list_project_simulations(socket.assigns.project.id)
       )
     )
     |> assign(:running, RenewCollabSim.Server.SimulationServer.running_ids() |> MapSet.new())}
  end

  def handle_info({:simulation_change, _, _}, socket) do
    {:noreply,
     socket
     |> assign(
       :simulations,
       RenewCollabSim.Simulator.list_simulations(
         RenewCollabProj.Projects.list_project_simulations(socket.assigns.project.id)
       )
     )
     |> assign(:running, RenewCollabSim.Server.SimulationServer.running_ids() |> MapSet.new())}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} project_id={@project.id} />

      <div style="padding: 1em">
        <.link navigate={~p"/projects"}>
          Projects
        </.link>
        / Simulations
      </div>

      <div style="padding: 1em">
        <h2 style="margin: 0;">Simulations</h2>

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
                    <.link navigate={~p"/simulation/#{sim.id}"}>
                      {sim.label || sim.id}
                    </.link>
                    <%= if sim.label do %>
                      <br /><small>{sim.id}</small>
                    <% end %>
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

  def handle_event("delete", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Simulator.delete_simulation(simulation_id)

    {:noreply, socket}
  end

  def handle_event("setup", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.SimulationServer.setup_and_wait(simulation_id)

    {:noreply,
     socket
     |> assign(:running, RenewCollabSim.Server.SimulationServer.running_ids() |> MapSet.new())}
  end

  def handle_event("stop", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.SimulationServer.terminate(simulation_id)

    {:noreply, socket}
  end

  def handle_event("step", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.SimulationServer.step(simulation_id)

    {:noreply, socket}
  end

  def handle_event("play", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.SimulationServer.play(simulation_id)

    {:noreply, socket}
  end

  def handle_event("pause", %{"id" => simulation_id}, socket) do
    RenewCollabSim.Server.SimulationServer.pause(simulation_id)

    {:noreply, socket}
  end
end
