defmodule RenewCollabWeb.LiveSimulation do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  @topic "simulation"

  def mount(%{"id" => simulation_id}, _session, socket) do
    socket =
      socket
      |> assign(:simulation_id, simulation_id)
      |> assign(:is_active, RenewCollabSim.Server.SimulationServer.exists(simulation_id))
      |> assign(:simulation, RenewCollabSim.Simulator.find_simulation(simulation_id))

    RenewCollabWeb.Endpoint.subscribe("#{@topic}:#{simulation_id}")

    {:ok, socket}
  end

  def handle_info(:any, socket) do
    {:noreply,
     socket
     |> assign(
       :simulation,
       RenewCollabSim.Simulator.find_simulation(socket.assigns.simulation_id)
     )}
  end

  def handle_info(:state, socket) do
    {:noreply,
     socket
     |> assign(
       :is_active,
       RenewCollabSim.Server.SimulationServer.exists(socket.assigns.simulation.id)
     )}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <header style="background: #333; color: #fff; padding: 1em; display: flex; justify-content: space-between;">
        <h1 style="margin: 0; font-size: 1.3em; display: flex; align-items: center; gap: 1ex">
          <img src="/favicon.svg" style="width: 1.5em; height: 1.5em" /> Renew Web Editor
        </h1>
        <.link style="color: white; align-self: center;" navigate={~p"/"}>Dashboard</.link>
      </header>

      <div style="padding: 1em">
        <.link navigate={~p"/shadow_net/#{@simulation.shadow_net_system_id}"}>Back</.link>
        <h2 style="margin: 0;">Simulation <%= @simulation.id %></h2>

        <dl>
          <dt>Timestep</dt>
          <dd><%= @simulation.timestep %></dd>
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
                <strong>Net: <%= ins.label %></strong>
                <dl style="display: grid; grid-template-columns: auto 1fr;">
                  <%= for {place, tokens} <- ins.tokens |> Enum.group_by(&(&1.place_id)) do %>
                    <dt>Place: <%= place %></dt>

                    <dd style="grid-column: 2 / span 1;">
                      Tokens:
                      <%= for t <- tokens do %>
                        <%= t.value %>
                      <% end %>
                    </dd>
                  <% end %>
                </dl>
              </li>
            <% end %>
          </ul>
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
        <div style="overflow: auto; max-height: 50vh;" phx-hook="RnwScrollDown" id="sim-scroll-logger">
          <div style="background: #333; color: #fff; font-family: monospace; margin: 0; padding: 0.5ex; line-height: 1.4;">
            <%= if Enum.empty?(@simulation.log_entries) do %>
              <p style="margin: 0; padding: 1ex; opacity: 0.7; font-style: italic;">
                &lt;Log is empty&gt;
              </p>
            <% else %>
              <ol style="list-style: none; padding: 0; margin: 0;">
                <%= for {e, ei} <- @simulation.log_entries|>Enum.with_index do %>
                  <li style={"padding: 1ex; background: #{if(rem(ei, 2) == 0, do: "#333", else: "#3a3a3a")}"}>
                    <%= e.content %>
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

  def handle_event("debug", %{}, socket) do
    %RenewCollabSim.Entites.SimulationLogEntry{
      simulation_id: socket.assigns.simulation_id,
      content: "Manual Test Entry"
    }
    |> RenewCollab.Repo.insert()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "#{@topic}:#{socket.assigns.simulation_id}",
      :any
    )

    {:noreply, socket}
  end

  def handle_event("clear_log", %{}, socket) do
    RenewCollabSim.Simulator.clear_log(socket.assigns.simulation_id)

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "#{@topic}:#{socket.assigns.simulation_id}",
      :any
    )

    {:noreply, socket}
  end

  def handle_event("clear_instances", %{}, socket) do
    RenewCollabSim.Simulator.clear_instances(socket.assigns.simulation_id)

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "#{@topic}:#{socket.assigns.simulation_id}",
      :any
    )

    {:noreply, socket}
  end

  def handle_event("reset", %{}, socket) do
    RenewCollabSim.Simulator.clear_instances(socket.assigns.simulation_id)
    RenewCollabSim.Simulator.clear_log(socket.assigns.simulation_id)

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "#{@topic}:#{socket.assigns.simulation_id}",
      :any
    )

    {:noreply, socket}
  end

  def handle_event("step", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.step(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("terminate", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.terminate(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("initialize", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.setup(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("delete", %{}, socket) do
    RenewCollabSim.Simulator.delete_simulation(socket.assigns.simulation_id)
    RenewCollabSim.Server.SimulationServer.terminate(socket.assigns.simulation.id)

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "shadow_net:#{socket.assigns.simulation.shadow_net_system_id}",
      :any
    )

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "shadow_nets",
      :any
    )

    {:noreply, socket}
  end
end