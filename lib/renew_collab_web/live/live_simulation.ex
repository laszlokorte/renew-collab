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
        <.link navigate={~p"/shadow_nets"}>Back</.link>
        <h2 style="margin: 0;">Simulation <%= @simulation.id %></h2>

        <dl>
          <dt>Main Net Name</dt>

          <dd><%= @simulation.shadow_net_system.main_net_name %></dd>
        </dl>

        <div style="margin: 1ex  0; display: flex; gap: 1ex">
          <%= if @is_active do %>
            <button type="button" phx-click="play">Play</button>
            <button type="button" phx-click="pause">Pause</button>
            <button type="button" phx-click="step">Step</button>
            <button type="button" phx-click="terminate">Terminate</button>
          <% else %>
            <button type="button" phx-click="run">run</button>
          <% end %>
          <button type="button" phx-click="clear_log">Clear Log</button>
          <button type="button" phx-click="clear_instances">Clear Instances</button>
        </div>

        <h3>Net Instances</h3>
        <ul>
          <%= for {ins, i} <- @simulation.net_instances|>Enum.with_index do %>
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

        <div style="overflow: auto; max-height: 50vh;" phx-hook="RnwScrollDown" id="sim-scroll-logger">
          <ol style="list-style: none; background: #333; color: #fff; font-family: monospace; margin: 0; padding: 0.5ex; line-height: 1.4;">
            <%= for {e, ei} <- @simulation.log_entries|>Enum.with_index do %>
              <li style={"padding: 1ex; background: #{if(rem(ei, 2) == 0, do: "#333", else: "#3a3a3a")}"}>
                <%= e.content %>
              </li>
            <% end %>
          </ol>
        </div>

        <div style="margin: 1ex  0; display: flex; gap: 1ex">
          <button type="button" phx-click="debug">Create Test Log Entry</button>
          <button type="button" phx-click="delete">delete</button>
        </div>
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

  def handle_event("step", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.step(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("play", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.play(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("pause", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.pause(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("terminate", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.terminate(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("run", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.setup(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("delete", %{}, socket) do
    RenewCollabSim.Simulator.delete_simulation(socket.assigns.simulation_id)

    # Phoenix.PubSub.broadcast(
    #   RenewCollab.PubSub,
    #   "#{@topic}:#{socket.assigns.simulation_id}",
    #   :any
    # )

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "shadow_nets",
      :any
    )

    {:noreply, socket}
  end
end
