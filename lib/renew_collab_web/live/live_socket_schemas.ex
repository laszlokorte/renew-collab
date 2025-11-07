defmodule RenewCollabWeb.LiveSocketSchemas do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  use RenewCollabCtrl.Helper,
    socket_schemas: {Views.GlobalSocketSchemasList, [], :socket_schema_changed}

  def load_param(:account, socket), do: socket.assigns.account

  def mount(_params, _session, socket) do
    socket
    |> assign(:create_form, to_form(%{"name" => nil}, as: :create_group))
    |> load_data(true)
  end

  def render(assigns) do
    assigns =
      assign(assigns,
        bounds: %{
          position_x: 0,
          position_y: 0,
          width: 100,
          height: 60
        }
      )

    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} />

      <div style="padding: 1em">
        / Socket Schemas
        <h2 style="margin: 0; display: flex; gap: 1ex; align-items: center;">
          <img class="icon" src="/assets/icon-socket.svg" />
          <span>
            Socket Schemas
          </span>
        </h2>
      </div>
      <div style="padding: 1em">
        <form phx-submit="create">
          <div style="display: flex; gap: 1ex; align-items: stretch">
            <input name="name" style="padding: 1ex" type="text" />
            <button style="background: #333; color: #fff; padding: 1ex; border: none">Create</button>
          </div>
        </form>

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="10">Preview</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="1000">Name</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="4">
                Actions
              </th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@socket_schemas) do %>
              <tr>
                <td colspan="6">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Socket Schemas defined yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {schema, si} <- @socket_schemas |> Enum.with_index do %>
                <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <svg viewBox={"#{@bounds.position_x - 10} #{@bounds.position_y - 10} #{@bounds.width + 20} #{@bounds.height + 20}"}>
                      <g fill="#ddd">
                        <%= case schema.stencil do %>
                          <% :ellipse -> %>
                            <ellipse
                              stroke-width="3"
                              pointer-events="none"
                              stroke-opacity="0.5"
                              fill-opacity="0.1"
                              cx={@bounds.position_x + @bounds.width / 2}
                              cy={@bounds.position_y + @bounds.height / 2}
                              fill="purple"
                              stroke="purple"
                              rx={@bounds.width / 2}
                              ry={@bounds.height / 2}
                            />
                          <% :rect -> %>
                            <rect
                              stroke-width="3"
                              pointer-events="none"
                              stroke-opacity="0.5"
                              fill-opacity="0.1"
                              x={@bounds.position_x}
                              y={@bounds.position_y}
                              fill="purple"
                              stroke="purple"
                              width={@bounds.width}
                              height={@bounds.height}
                            />
                          <% _ -> %>
                            <rect
                              stroke-width="3"
                              pointer-events="none"
                              stroke-opacity="0.5"
                              fill-opacity="0.5"
                              x={@bounds.position_x}
                              y={@bounds.position_y}
                              width={@bounds.width}
                              height={@bounds.height}
                            />
                        <% end %>
                      </g>
                      <%= for s <- schema.sockets do %>
                        <g pointer-events="all" fill="transparent">
                          <circle
                            cx={
                              RenewexIconset.Position.build_coord(
                                @bounds,
                                :x,
                                false,
                                RenewexIconset.Position.unify_coord(:x, s)
                              )
                            }
                            cy={
                              RenewexIconset.Position.build_coord(
                                @bounds,
                                :y,
                                false,
                                RenewexIconset.Position.unify_coord(:y, s)
                              )
                            }
                            fill="white"
                            stroke="purple"
                            opacity="0.4"
                            r={4}
                          />
                          <circle
                            cx={
                              RenewexIconset.Position.build_coord(
                                @bounds,
                                :x,
                                false,
                                RenewexIconset.Position.unify_coord(:x, s)
                              )
                            }
                            cy={
                              RenewexIconset.Position.build_coord(
                                @bounds,
                                :y,
                                false,
                                RenewexIconset.Position.unify_coord(:y, s)
                              )
                            }
                            pointer-events="none"
                            r={6}
                          />
                        </g>
                      <% end %>
                    </svg>
                  </td>
                  <td>
                    <.link style="color: #078" navigate={~p"/socket_schema/#{schema.id}"}>
                      {schema.name}
                    </.link>
                  </td>
                  <td width="50">
                    <button
                      style="cursor: pointer; background: #a00; color: #fff; padding: 1ex; border: none"
                      type="button"
                      phx-click="delete"
                      value={schema.id}
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

  def handle_event("create", attributes, socket) do
    %Actions.GlobalSocketSchemaCreate{attributes: attributes}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Socket Schema created")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Error creating Socket Schema")}
    end
  end

  def handle_event("delete", %{"value" => id}, socket) do
    %Actions.GlobalSocketSchemaDelete{socket_schema_id: id}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Socket Schema deleted")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Error deleting Socket Schema")}
    end
  end
end
