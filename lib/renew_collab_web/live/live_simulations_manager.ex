defmodule RenewCollabWeb.LiveSimulationsManager do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  def mount(_params, _session, socket) do
    socket = socket |> assign(load_data(socket.assigns.current_account))

    {:ok, socket}
  end

  def load_data(account) do
    %{
      simulations: %Views.GlobalSimulationsList{} |> Fetcher.fetch_as(account)
    }
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} />

      <div style="padding: 1em">
        Simulation Management
        <h2 style="margin: 0; display: flex; align-items: center; gap: 1ex;">
          <img class="icon" src="/assets/icon-simulation.svg" /> Manage Simulations
        </h2>
      </div>
      <div style="padding: 1em">
        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="1000">Name</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="200">Created</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="200">Last Updated</th>
              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="3">
                Actions
              </th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@simulations) do %>
              <tr>
                <td colspan="9">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Simulations yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {simulation, di} <- @simulations |> Enum.with_index do %>
                <tr {if(rem(di, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <.link
                      style="color: #078; display: flex; gap: 1ex;"
                      navigate={~p"/simulation/#{simulation.id}"}
                    >
                      <img class="icon" src="/assets/icon-simulation.svg" />
                      {simulation.label || simulation.id}
                    </.link>
                  </td>

                  <td>
                    <RenewCollabWeb.RenewComponents.timestamp value={simulation.inserted_at} />
                  </td>

                  <td>
                    <RenewCollabWeb.RenewComponents.timestamp value={simulation.inserted_at} />
                  </td>

                  <td width="50">
                    <button
                      type="button"
                      phx-click="delete_simulation"
                      phx-value-id={simulation.id}
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

  def handle_event("validate_simulation", params, socket) do
    {:noreply, assign(socket, create_form: to_form(params))}
  end

  def handle_event("delete_simulation", %{"id" => id}, socket) do
    %Actions.SimulationDeleteAsUser{simulation_id: id}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Simulation deleted")
        |> reload()

      _ ->
        {:noreply,
         socket
         |> put_flash(:info, "Simulation deletion failed")}
    end
  end

  def handle_info(:any, socket) do
    socket |> reload()
  end

  def reload(socket) do
    {:noreply, socket |> assign(load_data(socket.assigns.current_account))}
  end
end
