defmodule RenewCollabWeb.LiveIcon do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  @topic "icon"

  def mount(%{"id" => symbol_id}, _session, socket) do
    socket = assign(socket, :symbol_id, symbol_id)

    RenewCollabWeb.Endpoint.subscribe(@topic)

    {:ok, load_data(socket)}
  end

  defp load_data(socket) do
    socket |> assign(:icon, RenewCollab.Symbols.find_symbol(socket.assigns.symbol_id))
  end

  def render(assigns) do
    assigns =
      assign(assigns,
        bounds: %{
          position_x: 0,
          position_y: 0,
          width: 100,
          height: 60
        },
        padding: 150
      )

    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header />
      <div style="padding: 1em">
        <.link style="color: #078" navigate={~p"/icons"}>
          Back
        </.link>

        <h2 style="margin: 0;">Icon</h2>

        <div style="display: grid; grid-template-rows: 20em 1fr;">
          <svg
            style="height: 100%;"
            viewBox={"#{@bounds.position_x - @padding} #{@bounds.position_y - @padding} #{@bounds.width + 2* @padding} #{@bounds.height + 2* @padding}"}
          >
            <g style="color: red" stroke-width="2">
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
          </svg>

          <div>
            <h2>Paths</h2>

            <%= for path <- @icon.paths do %>
              <div>
                <h3>Path #{path.sort}</h3>

                <dl style="display: grid; grid-template-columns: auto auto; justify-content: start;">
                  <dt>fill_color</dt>
                  <dd>
                    <span style={"vertical-align: middle; border: 1px solid black; background: #{path.fill_color}; display: inline-block; width: 1em; height: 1em"}>
                    </span>{path.fill_color}
                  </dd>
                  <dt>stroke_color</dt>
                  <dd>
                    <span style={"vertical-align: middle; border: 1px solid black; background: #{path.stroke_color}; display: inline-block; width: 1em; height: 1em"}>
                    </span>{path.stroke_color}
                  </dd>
                </dl>

                <%= for segment <- path.segments do %>
                  <div>
                    <table border="1" cellpadding="5" cellspacing="0">
                      <thead>
                        <tr>
                          <th>Segment</th>
                          <td colspan="31">
                            {if(segment.relative, do: "relative", else: "absolute")}
                          </td>
                        </tr>
                        <tr>
                          <th rowspan="5" valign="bottom" align="left">Steps</th>
                          <th colspan="6" rowspan="1" valign="bottom">Horizontal</th>
                          <th colspan="6" rowspan="1" valign="bottom">Vertical</th>
                          <th colspan="15" rowspan="1" valign="bottom">Arc</th>
                        </tr>
                        <tr>
                          <th colspan="2" rowspan="2" valign="bottom">Relative</th>
                          <th colspan="4" rowspan="2" valign="bottom">Offset</th>
                          <th colspan="2" rowspan="2" valign="bottom">Relative</th>
                          <th colspan="4" rowspan="2" valign="bottom">Offset</th>
                          <th colspan="6" valign="bottom">X</th>
                          <th colspan="6" valign="bottom">Y</th>
                          <th rowspan="4" valign="bottom">angle</th>
                          <th rowspan="4" valign="bottom">sweep</th>
                          <th rowspan="4" valign="bottom">large</th>
                        </tr>

                        <tr>
                          <th colspan="2" valign="bottom">Relative</th>
                          <th colspan="4" valign="bottom">Offset</th>
                          <th colspan="2" valign="bottom">Relative</th>
                          <th colspan="4" valign="bottom">Offset</th>
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

                          <th>Value</th>
                          <th>Unit</th>
                          <th>Value</th>
                          <th>Unit</th>
                        </tr>
                      </thead>
                      <tbody>
                        <%= for step <- segment.steps do %>
                          <tr>
                            <td>{if(step.relative, do: "relative", else: "absolute")}</td>
                            <%= if step.horizontal do %>
                              <td>{step.horizontal.x_value}</td>
                              <td>{step.horizontal.x_unit}</td>
                              <td>{step.horizontal.x_offset_operation}</td>
                              <td>{step.horizontal.x_offset_value_static}</td>
                              <td>{step.horizontal.x_offset_dynamic_value}</td>
                              <td>{step.horizontal.x_offset_dynamic_unit}</td>
                            <% else %>
                              <td colspan="6" align="center">-</td>
                            <% end %>
                            <%= if step.vertical do %>
                              <td>{step.vertical.y_value}</td>
                              <td>{step.vertical.y_unit}</td>
                              <td>{step.vertical.y_offset_operation}</td>
                              <td>{step.vertical.y_offset_value_static}</td>
                              <td>{step.vertical.y_offset_dynamic_value}</td>
                              <td>{step.vertical.y_offset_dynamic_unit}</td>
                            <% else %>
                              <td colspan="6" align="center">-</td>
                            <% end %>
                            <%= if step.arc do %>
                              <td>{step.arc.rx_value}</td>
                              <td>{step.arc.rx_unit}</td>
                              <td>{step.arc.rx_offset_operation}</td>
                              <td>{step.arc.rx_offset_value_static}</td>
                              <td>{step.arc.rx_offset_dynamic_value}</td>
                              <td>{step.arc.rx_offset_dynamic_unit}</td>
                              <td>{step.arc.ry_value}</td>
                              <td>{step.arc.ry_unit}</td>
                              <td>{step.arc.ry_offset_operation}</td>
                              <td>{step.arc.ry_offset_value_static}</td>
                              <td>{step.arc.ry_offset_dynamic_value}</td>
                              <td>{step.arc.ry_offset_dynamic_unit}</td>
                              <td>{step.arc.angle}</td>
                              <td>{step.arc.sweep}</td>
                              <td>{step.arc.large}</td>
                            <% else %>
                              <td colspan="15" align="center">-</td>
                            <% end %>
                          </tr>
                        <% end %>
                      </tbody>
                    </table>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
