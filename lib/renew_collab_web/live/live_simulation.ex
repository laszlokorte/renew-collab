defmodule RenewCollabWeb.LiveSimulation do
  alias RenewCollabProj.Entites.ProjectSimulation
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  @topic "simulation"

  def mount(%{"id" => simulation_id}, _session, socket) do
    RenewCollabSim.Simulator.find_simulation(simulation_id)
    |> case do
      nil ->
        {:ok, socket |> put_flash(:error, "Simulation not found") |> redirect(to: ~p"/projects")}

      sim ->
        project_id =
          if(sim.project_assignment,
            do: sim.project_assignment.project_id,
            else: sim.shadow_net_system.project_assignment.project_id
          )

        socket =
          socket
          |> assign(:simulation_id, simulation_id)
          |> assign(:project_id, project_id)
          |> assign(:rename_form, to_form(%{"name" => sim.label}))
          |> assign(:show_transitions, false)
          |> assign(
            :is_active,
            RenewCollabSim.Server.ProjectSimulationServer.exists(
              project_id,
              simulation_id
            )
          )
          |> assign(:simulation, sim)

        # TODO:subscription
        RenewCollabWeb.Endpoint.subscribe("#{@topic}:#{simulation_id}")

        {:ok, socket}
    end
  end

  def handle_info({:simulation_change, sim_id, _}, socket) do
    if sim_id == socket.assigns.simulation_id do
      RenewCollabSim.Simulator.find_simulation(socket.assigns.simulation_id)
      |> case do
        nil ->
          {:noreply,
           socket
           |> redirect(to: ~p"/shadow_net/#{socket.assigns.simulation.shadow_net_system_id}")}

        sim ->
          {:noreply,
           socket
           |> assign(
             :simulation,
             sim
           )
           |> assign(
             :is_active,
             RenewCollabSim.Server.ProjectSimulationServer.exists(
               sim.project_assignment.project_id,
               sim_id
             )
           )}
      end
    end
  end

  def handle_info(:state, socket) do
    {:noreply,
     socket
     |> assign(
       :is_active,
       RenewCollabSim.Server.ProjectSimulationServer.exists(
         socket.assigns.simulation.project_assignment.project_id,
         socket.assigns.simulation.id
       )
     )}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header
        flash={@flash}
        tab={:simulations}
        project_id={@project_id}
      />

      <div style="padding: 1em">
        <.link navigate={~p"/projects"}>
          Projects
        </.link>
        <%= case @simulation.project_assignment do %>
          <% %ProjectSimulation{project_id: project_id} -> %>
            /
            <.link navigate={~p"/project/#{project_id}/shadow_nets"} style="color: inherit">
              Shadow Net Systems
            </.link>
          <% _ -> %>
        <% end %>
        /
        <.link navigate={~p"/shadow_net/#{@simulation.shadow_net_system_id}"}>
          Simulations
        </.link>
        / Simulation
        <h2 style="margin: 0; display: flex; gap: 1ex; align-items: start;">
          <img class="icon" src="/assets/icon-simulation.svg" />
          <span>
            Simulation {@simulation.label || "Untitled"}<br />
            (<small><code>{@simulation.id}</code></small>)
          </span>
        </h2>
        <div style="padding: 1em 1em 0; display: flex; align-items: start; gap: 1em">
          <fieldset style="margin-bottom: 1em">
            <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
              Progress
            </legend>
            <dl style="display: grid; grid-template-columns: auto 1fr;">
              <dt>Timestep</dt>

              <dd>{@simulation.timestep}</dd>
            </dl>

            <div style="margin: 1ex  0; display: flex; gap: 1ex">
              <%= if @is_active do %>
                <button
                  type="button"
                  phx-click="step"
                  style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                >
                  Step
                </button>

                <button
                  type="button"
                  phx-click="play"
                  style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                >
                  play
                </button>

                <button
                  type="button"
                  phx-click="pause"
                  style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                >
                  pause
                </button>

                <button
                  type="button"
                  phx-click="terminate"
                  style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a3a; color: #fff"
                >
                  Terminate
                </button>
              <% else %>
                <button
                  type="button"
                  phx-click="initialize"
                  style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                >
                  Initialize
                </button>

                <button
                  type="button"
                  phx-click="reset"
                  style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a61; color: #fff"
                >
                  Clear all recorded data
                </button>
              <% end %>
            </div>
          </fieldset>

          <fieldset style="margin-bottom: 1em">
            <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
              Rename Simulation
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
        <h3>Net Instances</h3>

        <%= if Enum.empty?(@simulation.net_instances) do %>
          <p style="margin: 0; padding: 1ex; opacity: 0.7; font-style: italic;">
            &lt;No Net instances recorded yet.&gt;
          </p>
        <% else %>
          <button
            type="button"
            phx-click="clear_instances"
            style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a61; color: #fff"
          >
            Clear Instances
          </button>

          <ul>
            <%= for ins <- @simulation.net_instances do %>
              <li>
                <strong>Net: {ins.label}</strong>
                <dl style="display: grid; grid-template-columns: auto 1fr;">
                  <%= for {place, tokens} <- ins.tokens |> Enum.group_by(&(&1.place_id)) do %>
                    <dt>Place: {place}</dt>

                    <dd style="grid-column: 2 / span 1;">
                      Tokens:
                      <%= for t <- tokens do %>
                        {t.value}
                      <% end %>
                    </dd>
                  <% end %>
                </dl>
              </li>
            <% end %>
          </ul>
        <% end %>

        <h3>Firing sequence</h3>

        <%= if Enum.empty?(@simulation.net_instances) do %>
          <p style="margin: 0; padding: 1ex; opacity: 0.7; font-style: italic;">
            &lt;No Transition firings recorded yet.&gt;
          </p>
        <% else %>
          <details id="transition-log" open={@show_transitions}>
            <summary style="cursor: pointer;" phx-click="toggle-transition">Show</summary>

            <div style="max-height:10em; overflow: auto; overscroll-behavior: contain;">
              <dl>
                <%= for net <- @simulation.net_instances do %>
                  <dt>
                    <strong>Net: {net.label}</strong>
                  </dt>

                  <dd>
                    <dl style="display: grid; grid-template-columns: auto 1fr;">
                      <ol style="list-style: none">
                        <%= for fir <- net.firings |> Enum.reverse() do %>
                          <li>Transition {fir.transition_id} (time: {fir.timestep})</li>
                        <% end %>
                      </ol>
                    </dl>
                  </dd>
                <% end %>
              </dl>
            </div>
          </details>
        <% end %>

        <h3>Simulation Log</h3>

        <div style="margin: 1ex  0; display: flex; gap: 1ex">
          <button
            type="button"
            phx-click="clear_log"
            style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a61; color: #fff"
          >
            Clear Log
          </button>

          <button
            type="button"
            phx-click="debug"
            style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
          >
            Create Test Log Entry
          </button>
        </div>

        <div
          style="overflow: auto; max-height: 50vh; overscroll-behavior: contain;"
          phx-hook="RnwScrollDown"
          id="sim-scroll-logger"
        >
          <div style="background: #333; color: #fff; font-family: monospace; margin: 0; padding: 0.5ex; line-height: 1.4;">
            <%= if Enum.empty?(@simulation.log_entries) do %>
              <p style="margin: 0; padding: 1ex; opacity: 0.7; font-style: italic;">
                &lt;Log is empty&gt;
              </p>
            <% else %>
              <ol style="list-style: none; padding: 0; margin: 0;">
                <%= for {e, ei} <- @simulation.log_entries|>Enum.with_index do %>
                  <li style={"padding: 1ex; background: #{if(rem(ei, 2) == 0, do: "#333", else: "#3a3a3a")}"}>
                    {e.content}
                  </li>
                <% end %>
              </ol>
            <% end %>
          </div>
        </div>

        <h3>Delete</h3>

        <button
          type="button"
          phx-click="delete"
          style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
        >
          Delete Simulation
        </button>
      </div>
    </div>
    """
  end

  def handle_event("validate-rename", %{"name" => new_name}, socket) do
    {:noreply, socket |> assign(:rename_form, to_form(%{"name" => new_name}))}
  end

  def handle_event("rename", %{"name" => new_name}, socket) do
    RenewCollabSim.Simulator.rename_simulation(
      socket.assigns.simulation_id,
      new_name
    )

    {:noreply, socket |> put_flash(:info, "Simulation name changed")}
  end

  def handle_event("debug", %{}, socket) do
    RenewCollabSim.Simulator.add_manual_log_entry(
      socket.assigns.simulation_id,
      "Manual Test Entry"
    )

    {:noreply, socket}
  end

  def handle_event("toggle-transition", %{}, socket) do
    {:noreply, assign(socket, :show_transitions, not socket.assigns.show_transitions)}
  end

  def handle_event("clear_log", %{}, socket) do
    RenewCollabSim.Simulator.clear_log(socket.assigns.simulation_id)

    # TODO:broadcast
    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "#{@topic}:#{socket.assigns.simulation_id}",
      {:simulation_change, socket.assigns.simulation_id, :log}
    )

    {:noreply, socket |> put_flash(:info, "Simulation log cleared")}
  end

  def handle_event("clear_instances", %{}, socket) do
    RenewCollabSim.Simulator.clear_instances(socket.assigns.simulation_id)

    # TODO:broadcast
    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "#{@topic}:#{socket.assigns.simulation_id}",
      {:simulation_change, socket.assigns.simulation_id, :records}
    )

    {:noreply, socket |> put_flash(:info, "Simulation net instances cleared")}
  end

  def handle_event("reset", %{}, socket) do
    RenewCollabSim.Simulator.reset_time(socket.assigns.simulation_id)
    RenewCollabSim.Simulator.clear_instances(socket.assigns.simulation_id)
    RenewCollabSim.Simulator.clear_log(socket.assigns.simulation_id)

    # TODO:broadcast
    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "#{@topic}:#{socket.assigns.simulation_id}",
      {:simulation_change, socket.assigns.simulation_id, :reset}
    )

    {:noreply, socket}
  end

  def handle_event("step", %{}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.step(
      socket.assigns.project_id,
      socket.assigns.simulation.id
    )

    {:noreply, socket}
  end

  def handle_event("play", %{}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.play(
      socket.assigns.project_id,
      socket.assigns.simulation.id
    )

    {:noreply, socket}
  end

  def handle_event("pause", %{}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.pause(
      socket.assigns.project_id,
      socket.assigns.simulation.id
    )

    {:noreply, socket}
  end

  def handle_event("terminate", %{}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.stop(
      socket.assigns.project_id,
      socket.assigns.simulation.id
    )

    {:noreply, socket}
  end

  def handle_event("initialize", %{}, socket) do
    RenewCollabSim.Server.ProjectSimulationServer.setup(
      socket.assigns.project_id,
      socket.assigns.simulation.id
    )

    {:noreply, socket}
  end

  def handle_event("delete", %{}, socket) do
    shadow_net_system_id = socket.assigns.simulation.shadow_net_system_id
    RenewCollabSim.Simulator.delete_simulation(socket.assigns.simulation_id)

    RenewCollabSim.Server.ProjectSimulationServer.stop(
      socket.assigns.project_id,
      socket.assigns.simulation.id
    )

    {:noreply, socket |> redirect(to: ~p"/shadow_net/#{shadow_net_system_id}")}
  end
end
