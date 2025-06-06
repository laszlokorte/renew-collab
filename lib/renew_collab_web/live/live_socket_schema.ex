defmodule RenewCollabWeb.LiveSocketSchema do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  @topic "socket_schema"

  @dims [:width, :height, :minsize, :maxsize]
  @funcs [:sum, :min, :max]

  def dims(), do: @dims
  def funcs(), do: @funcs

  def mount(%{"id" => socket_schema_id}, _session, socket) do
    socket =
      socket
      |> assign(:socket_schema_id, socket_schema_id)
      |> assign(:icons, RenewCollab.Symbols.list_shapes())
      |> assign(:icon, nil)
      |> assign(:preview, %RenewCollab.Connection.Socket{})

    RenewCollabWeb.Endpoint.subscribe("#{@topic}-socket_schema_id")

    {:ok, load_data(socket)}
  end

  defp load_data(socket) do
    socket
    |> assign(:schema, RenewCollab.Sockets.find_socket_schema(socket.assigns.socket_schema_id))
  end

  def render(assigns) do
    assigns =
      assign(assigns, :bounds, %{
        position_x: 0,
        position_y: 0,
        width: 100,
        height: 60
      })

    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header />
      <div style="padding: 1em">
        <.link style="color: #078" navigate={~p"/socket_schemas"}>
          Back
        </.link>

        <h2 style="margin: 0;">Socket Schema</h2>

        <div style="display: grid; grid-template-columns: 20em 1fr;">
          <div>
            <svg viewBox={"#{@bounds.position_x - 10} #{@bounds.position_y - 10} #{@bounds.width + 20} #{@bounds.height + 20}"}>
              <%= if @icon do %>
                <g opacity="0.3" style="color: red" stroke-width="2" fill="white" stroke="black">
                  <%= for path <- @icon.paths do %>
                    <path
                      stroke-linejoin="bevel"
                      stroke={path.stroke_color}
                      fill={path.fill_color}
                      d={RenewexIconset.Builder.build_symbol_path(@bounds, path)}
                      fill-rule="evenodd"
                    />
                  <% end %>
                </g>
              <% end %>

              <g fill="#ddd">
                <%= case @schema.stencil do %>
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
              <%= for s <- @schema.sockets do %>
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
                    pointer-events="none"
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
                    pointer-events="all"
                    title={s.name}
                    r={6}
                  >
                    <title>{s.name}</title>
                  </circle>
                </g>
              <% end %>

              <%= with s when @preview.name != nil <- @preview do %>
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
                    stroke="#1abc9c"
                    opacity="0.9"
                    pointer-events="none"
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
                    pointer-events="all"
                    title={s.name}
                    r={6}
                  >
                    <title>{s.name}</title>
                  </circle>
                </g>
                <% else _ -> %>
              <% end %>
            </svg>
            <form phx-change="change_preview">
              <select name="icon_id">
                <option value="">None</option>
                <%= for i <- @icons do %>
                  <option value={i.id}>{i.name}</option>
                <% end %>
              </select>
            </form>
          </div>
          <div>
            <h3>Stencil</h3>
            <form id="stencil_form" phx-change="change_stencil">
              <p>
                <select name="stencil">
                  <option selected={@schema.stencil == nil} value="">None</option>
                  <option selected={@schema.stencil == :ellipse} value="ellipse">Ellipse</option>
                  <option selected={@schema.stencil == :rect} value="rect">Rect</option>
                </select>
              </p>
            </form>
            <h3>Sockets</h3>

            <table border="1" cellpadding="5" cellspacing="0">
              <thead>
                <tr>
                  <th rowspan="3" valign="bottom" align="left">Name</th>
                  <th colspan="2" valign="bottom">X Position</th>
                  <th colspan="4" valign="bottom">X Offset</th>
                  <th colspan="2" valign="bottom">Y Position</th>
                  <th colspan="4" valign="bottom">Y Offset</th>
                  <th colspan="1" rowspan="3" valign="bottom"></th>
                </tr>
                <tr>
                  <th rowspan="2" valign="bottom">Value</th>
                  <th rowspan="2" valign="bottom">Unit</th>
                  <th rowspan="2" valign="bottom">Operation</th>
                  <th rowspan="2" valign="bottom">Static</th>
                  <th colspan="2" valign="bottom">Dynamic</th>

                  <th rowspan="2" valign="bottom">Value</th>
                  <th rowspan="2" valign="bottom">Unit</th>
                  <th rowspan="2" valign="bottom">Operation</th>
                  <th rowspan="2" valign="bottom">Static</th>
                  <th colspan="2" valign="bottom">Dynamic</th>
                </tr>

                <tr>
                  <th>Value</th>
                  <th>Unit</th>

                  <th>Value</th>
                  <th>Unit</th>
                </tr>
              </thead>
              <tbody>
                <%= for s <- @schema.sockets do %>
                  <tr>
                    <td>{s.name}</td>

                    <td>{s.x_value}</td>
                    <td>{s.x_unit}</td>
                    <td>{s.x_offset_operation}</td>
                    <td>{s.x_offset_value_static}</td>
                    <td>{s.x_offset_dynamic_value}</td>
                    <td>{s.x_offset_dynamic_unit}</td>
                    <td>{s.y_value}</td>
                    <td>{s.y_unit}</td>
                    <td>{s.y_offset_operation}</td>
                    <td>{s.y_offset_value_static}</td>
                    <td>{s.y_offset_dynamic_value}</td>
                    <td>{s.y_offset_dynamic_unit}</td>
                    <td>
                      <button type="button" phx-click="delete_socket" value={s.id}>Delete</button>
                      <button type="button" phx-click="copy_socket" value={s.id}>Copy</button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
              <tfoot>
                <tr>
                  <td><input form="create_form" type="text" name="name" value={@preview.name} /></td>

                  <td>
                    <input
                      form="create_form"
                      type="number"
                      step="0.01"
                      size="4"
                      name="x_value"
                      value={@preview.x_value}
                    />
                  </td>
                  <td>
                    <select form="create_form" name="x_unit">
                      <%= for d <- dims() do %>
                        <option selected={d == @preview.x_unit}>{d}</option>
                      <% end %>
                    </select>
                  </td>
                  <td>
                    <select form="create_form" name="x_offset_operation">
                      <%= for f <- funcs() do %>
                        <option selected={f == @preview.x_offset_operation}>{f}</option>
                      <% end %>
                    </select>
                  </td>
                  <td>
                    <input
                      form="create_form"
                      type="number"
                      step="0.01"
                      size="4"
                      name="x_offset_value_static"
                      value={@preview.x_offset_value_static}
                    />
                  </td>
                  <td>
                    <input
                      form="create_form"
                      type="number"
                      step="0.01"
                      size="4"
                      name="x_offset_dynamic_value"
                      value={@preview.x_offset_dynamic_value}
                    />
                  </td>
                  <td>
                    <select form="create_form" name="x_offset_dynamic_unit">
                      <%= for d <- dims() do %>
                        <option selected={d == @preview.x_offset_dynamic_unit}>{d}</option>
                      <% end %>
                    </select>
                  </td>
                  <td>
                    <input
                      form="create_form"
                      type="number"
                      step="0.01"
                      size="4"
                      name="y_value"
                      value={@preview.y_value}
                    />
                  </td>
                  <td>
                    <select form="create_form" name="y_unit">
                      <%= for d <- dims() do %>
                        <option selected={d == @preview.y_unit}>{d}</option>
                      <% end %>
                    </select>
                  </td>
                  <td>
                    <select form="create_form" name="y_offset_operation">
                      <%= for f <- funcs() do %>
                        <option selected={f == @preview.y_offset_operation}>{f}</option>
                      <% end %>
                    </select>
                  </td>
                  <td>
                    <input
                      form="create_form"
                      type="number"
                      step="0.01"
                      size="4"
                      name="y_offset_value_static"
                      value={@preview.y_offset_value_static}
                    />
                  </td>
                  <td>
                    <input
                      form="create_form"
                      type="number"
                      step="0.01"
                      size="4"
                      name="y_offset_dynamic_value"
                      value={@preview.y_offset_dynamic_value}
                    />
                  </td>
                  <td>
                    <select form="create_form" name="y_offset_dynamic_unit">
                      <%= for d <- dims() do %>
                        <option selected={d == @preview.y_offset_dynamic_unit}>{d}</option>
                      <% end %>
                    </select>
                  </td>
                  <td>
                    <form id="create_form" phx-submit="create_socket" phx-change="preview_socket">
                      <input type="hidden" name="socket_schema_id" value={@schema.id} />
                      <button type="submit">Create</button>
                    </form>
                  </td>
                </tr>
              </tfoot>
            </table>

            <details>
              <summary>Export</summary>
              <textarea style="width: 50%; min-height: 12em;" readonly>{inspect(@schema, pretty: true)}</textarea>
            </details>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("change_stencil", params, socket) do
    RenewCollab.Sockets.change_schema(socket.assigns.socket_schema_id, params)

    {:noreply, load_data(socket)}
  end

  def handle_event("delete_socket", %{"value" => id}, socket) do
    RenewCollab.Sockets.delete_socket(id)

    {:noreply, load_data(socket)}
  end

  def handle_event("copy_socket", %{"value" => id}, socket) do
    {:noreply,
     update(
       socket,
       :preview,
       fn s ->
         s
         |> RenewCollab.Connection.Socket.changeset(
           RenewCollab.Sockets.find_socket(id)
           |> Map.from_struct()
           |> Map.delete(:id)
           |> Map.delete(:name)
         )
         |> Ecto.Changeset.apply_changes()
       end
     )}
  end

  def handle_event("create_socket", params, socket) do
    RenewCollab.Sockets.create_socket(params)

    {:noreply,
     load_data(socket)
     |> assign(:preview, %RenewCollab.Connection.Socket{})}
  end

  def handle_event("preview_socket", params, socket) do
    {:noreply,
     update(
       socket,
       :preview,
       fn s ->
         s
         |> RenewCollab.Connection.Socket.changeset(params)
         |> Ecto.Changeset.apply_changes()
       end
     )}
  end

  def handle_event("change_preview", %{"icon_id" => ""}, socket) do
    {:noreply, socket |> assign(:icon, nil)}
  end

  def handle_event("change_preview", %{"icon_id" => icon_id}, socket) do
    {:noreply, socket |> assign(:icon, RenewCollab.Symbols.find_symbol(icon_id))}
  end
end
