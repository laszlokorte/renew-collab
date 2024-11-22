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

        <div>
          <%= if @is_active do %>
            <button type="button" phx-click="play">Play</button>
            <button type="button" phx-click="pause">Pause</button>
            <button type="button" phx-click="step">Step</button>
            <button type="button" phx-click="terminate">Terminate</button>
          <% else %>
            <button type="button" phx-click="run">run</button>
          <% end %>
          <button type="button" phx-click="clear">Clear Log</button>
        </div>

        <ol>
          <%= for e <- @simulation.log_entries do %>
            <li><%= e.content %></li>
          <% end %>
        </ol>
        <button type="button" phx-click="debug">Create Test Log Entry</button> <hr />
        <button type="button" phx-click="delete">delete</button>
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

  def handle_event("clear", %{}, socket) do
    RenewCollabSim.Simulator.clear_log(socket.assigns.simulation_id)

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      "#{@topic}:#{socket.assigns.simulation_id}",
      :any
    )

    {:noreply, socket}
  end

  def handle_event("step", %{}, socket) do
    {:noreply, socket}
  end

  def handle_event("terminate", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.terminate(socket.assigns.simulation.id)

    {:noreply, socket}
  end

  def handle_event("run", %{}, socket) do
    RenewCollabSim.Server.SimulationServer.setup(socket.assigns.simulation.id)

    {:noreply, socket}

    # s = self()

    # spawn_link(fn ->
    #   output_root = Path.join(System.tmp_dir!(), "#{UUID.uuid4(:default)}")
    #   output_root_upload = Path.join(output_root, "uploads")
    #   sns_path = Path.join(output_root, "compiled.ssn")
    #   script_path = Path.join(output_root, "compile-script")

    #   File.mkdir_p(output_root_upload)

    #   script_content =
    #     [
    #       "keepalive on",
    #       "startsimulation #{sns_path} #{socket.assigns.simulation.shadow_net_system.main_net_name} -i"
    #     ]
    #     |> Enum.join("\n")

    #   File.write!(script_path, script_content)
    #   File.write!(sns_path, socket.assigns.simulation.shadow_net_system.compiled)

    #   port =
    #     RenewCollabSim.Script.Runner.start_and_collect(script_path, fn log ->
    #       %RenewCollabSim.Entites.SimulationLogEntry{
    #         simulation_id: socket.assigns.simulation_id,
    #         content: log
    #       }
    #       |> RenewCollab.Repo.insert()

    #       Phoenix.PubSub.broadcast(
    #         RenewCollab.PubSub,
    #         "#{@topic}:#{socket.assigns.simulation_id}",
    #         :any
    #       )
    #     end)

    #   send(s, {:port, port})
    # end)

    # receive do
    #   {:port, p} ->
    #     dbg(p)
    #     {:noreply, socket |> assign(:is_active, p)}
    # end
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
