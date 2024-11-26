defmodule RenewCollabWeb.LiveShadowNet do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  @topic "shadow_nets"

  def mount(%{"id" => shadow_net_system_id}, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)

    socket =
      socket
      |> assign(:shadow_net_system_id, shadow_net_system_id)
      |> assign(
        :shadow_net_system,
        RenewCollabSim.Simulator.find_shadow_net_system(shadow_net_system_id)
      )

    {:ok, socket}
  end

  def handle_info(:any, socket) do
    {:noreply,
     socket
     |> assign(
       :shadow_net_system,
       RenewCollabSim.Simulator.find_shadow_net_system(socket.assigns.shadow_net_system_id)
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
      </div>

      <div style="padding: 1em">
        <h2 style="margin: 0;">Shadow Net System <%= @shadow_net_system.id %></h2>

        <dl style="display: grid; grid-template-columns: auto 1fr;">
          <dt>Main Net Name</dt>

          <dd><code><%= @shadow_net_system.main_net_name %></code></dd>

          <dt>Net Definitions</dt>

          <dd>
            <ul style="list-style: none; margin: 0; padding: 0;">
              <%= for net <- @shadow_net_system.nets do %>
                <li><code><%= net.name %></code></li>
              <% end %>
            </ul>
          </dd>
        </dl>

        <div>
          <button
            type="button"
            phx-click="new-simulation"
            style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            New Simulation
          </button>

          <a style="color: #078" href={~p"/shadow_net/#{@shadow_net_system.id}/binary"}>
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

              <th style="border-bottom: 1px solid #333;" align="left" width="100%">Timestep</th>

              <th style="border-bottom: 1px solid #333;" align="left">Actions</th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@shadow_net_system.simulations) do %>
              <tr>
                <td colspan="7">
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
              <%= for {sim,si} <- @shadow_net_system.simulations |> Enum.with_index do %>
                <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <.link navigate={~p"/simulation/#{sim.id}"}>
                      <%= sim.id %>
                    </.link>
                  </td>

                  <td>
                    <%= sim.timestep %>
                  </td>

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
    RenewCollabSim.Server.SimulationServer.terminate(simulation_id)

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      @topic,
      :any
    )

    {:noreply, socket}
  end

  def handle_event("new-simulation", %{}, socket) do
    %RenewCollabSim.Entites.Simulation{
      shadow_net_system_id: socket.assigns.shadow_net_system_id
    }
    |> RenewCollab.Repo.insert()
    |> case do
      {:ok, %{id: id}} -> RenewCollabSim.Server.SimulationServer.setup(id)
    end

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      @topic,
      :any
    )

    {:noreply, socket}
  end
end
