defmodule RenewCollabWeb.LiveSimulation do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabProj.Entities.ProjectSimulation
  use RenewCollabWeb, :live_view
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  use RenewCollabCtrl.Helper,
    simulation: {Views.SimulationWithState, [:simulation_id], :simulation_change},
    is_active: {Views.SimulationIsActive, [:project_id, :simulation_id], :simulation_change}

  def load_param(:simulation_id, %{assigns: %{simulation_id: id}}), do: id
  def load_param(:simulation_id, _socket), do: nil
  def load_param(:account_id, socket), do: socket.assigns.current_account.id

  def load_param(:project_id, %{assigns: %{simulation: %{project_assignment: %{project_id: id}}}}),
      do: id

  def load_param(:project_id, _socket), do: nil

  def mount(%{"id" => simulation_id}, _session, socket) do
    socket
    |> assign(:simulation_id, simulation_id)
    |> load_data(true)
    |> case do
      {:error, socket} ->
        {:ok, socket |> put_flash(:error, "Project not found") |> redirect(to: ~p"/projects")}

      {:ok, socket = %{assigns: %{simulation: sim}}} ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "simulation:#{sim.id}")

        socket
        |> assign(:rename_form, to_form(%{"name" => sim.label}))
        |> assign(:show_transitions, false)
        |> then(&{:ok, &1})
    end
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header
        flash={@flash}
        tab={:simulations}
        project_id={@simulation.project_assignment && @simulation.project_assignment.project_id}
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
          <img class="icon" src="/images/icon-simulation.svg" />
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
            phx-click="debug-log"
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
    %Actions.SimulationRename{simulation_id: socket.assigns.simulation.id, new_name: new_name}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Simulation name changed")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Renaming Simulaton failed")}
    end
  end

  def handle_event("debug-log", %{}, socket) do
    %Actions.SimulationLogDebug{
      simulation_id: socket.assigns.simulation.id,
      message: "Manual Test Entry"
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Added Debug Log Entry")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Adding Debug Log entry failed")}
    end
  end

  def handle_event("toggle-transition", %{}, socket) do
    {:noreply, assign(socket, :show_transitions, not socket.assigns.show_transitions)}
  end

  def handle_event("clear_log", %{}, socket) do
    %Actions.SimulationLogClear{
      simulation_id: socket.assigns.simulation.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Simulation log cleared")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Clearing failed")}
    end
  end

  def handle_event("clear_instances", %{}, socket) do
    %Actions.SimulationInstancesClear{
      simulation_id: socket.assigns.simulation.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Simulation instances cleared")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Clearing failed")}
    end
  end

  def handle_event("reset", %{}, socket) do
    %Actions.SimulationReset{
      simulation_id: socket.assigns.simulation.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Simulation reset")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Reset failed")}
    end
  end

  def handle_event("step", %{}, socket) do
    %Actions.SimulationStep{
      simulation_id: socket.assigns.simulation.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Stepping")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Stepping failed failed")}
    end
  end

  def handle_event("play", %{}, socket) do
    %Actions.SimulationPlay{
      simulation_id: socket.assigns.simulation.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Start playing simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Playing simulation failed")}
    end
  end

  def handle_event("pause", %{}, socket) do
    %Actions.SimulationPause{
      simulation_id: socket.assigns.simulation.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Pause playing simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Pausing simulation failed")}
    end
  end

  def handle_event("terminate", %{}, socket) do
    %Actions.SimulationTerminate{
      simulation_id: socket.assigns.simulation.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Terminating simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Termination failed")}
    end
  end

  def handle_event("initialize", %{}, socket) do
    %Actions.SimulationInitialize{
      simulation_id: socket.assigns.simulation.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply, socket |> put_flash(:info, "Initializing simulation")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Initializing simulation failed")}
    end
  end

  def handle_event("delete", %{}, socket) do
    %Actions.SimulationDeleteAsUser{simulation_id: socket.assigns.simulation.id}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        {:noreply,
         socket
         |> redirect(to: ~p"/shadow_net/#{socket.assigns.simulation.shadow_net_system_id}")
         |> put_flash(:info, "Simulation deleted")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Failed to delete simulation")}
    end
  end
end
