defmodule RenewCollabWeb.HierarchyLayerBoxComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <g
      id={"box-#{@layer.box.id}"}
      stroke-dasharray={style_or_default(@layer, :border_dash_array)}
      stroke-width={style_or_default(@layer, :border_width)}
      fill={style_or_default(@layer, :background_color)}
      stroke={style_or_default(@layer, :border_color)}
      opacity={style_or_default(@layer, :opacity)}
    >
      <%= if @layer.box.symbol_shape_id do %>
        <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
          <%= case symbols[@layer.box.symbol_shape_id].name do %>
            <% "rect-round" -> %>
              <rect
                id={"roundrect-#{@layer.box.id}"}
                rx={(@layer.box.symbol_shape_attributes["rx"] || 0) / 2}
                ry={(@layer.box.symbol_shape_attributes["ry"] || 0) / 2}
                x={@layer.box.position_x}
                y={@layer.box.position_y}
                width={@layer.box.width}
                height={@layer.box.height}
              >
              </rect>
            <% "pie" -> %>
              <path
                id={"pie-#{@layer.box.id}"}
                d={
                  pie_path(
                    @layer.box,
                    @layer.box.symbol_shape_attributes["start_angle"],
                    @layer.box.symbol_shape_attributes["end_angle"]
                  )
                }
                fill-rule="evenodd"
              />
            <% _ -> %>
              <g id={"symbol-#{@layer.box.id}-#{@layer.box.symbol_shape_id}"}>
                <%= for path <- symbols[@layer.box.symbol_shape_id].paths do %>
                  <path
                    stroke-linejoin="bevel"
                    stroke={path.stroke_color}
                    fill={path.fill_color}
                    d={RenewexIconset.Builder.build_symbol_path(@layer.box, path)}
                    fill-rule="evenodd"
                  />
                <% end %>
              </g>
          <% end %>
          <% else _ -> %>
            <rect
              id={"_loading-#{@layer.box.id}"}
              x={@layer.box.position_x}
              y={@layer.box.position_y}
              width={@layer.box.width}
              height={@layer.box.height}
              fill-opacity="0.4"
              stroke="black"
              opacity="0.5"
              stroke-width="3"
              vector-effect="non-scaling-stroke"
              stroke-dasharray="4 4"
            >
            </rect>
            <text
              x={@layer.box.position_x + @layer.box.width / 2}
              y={@layer.box.position_y + @layer.box.height / 2}
              font-size="12"
              text-anchor="middle"
              dominant-baseline="center"
              font-family="monospace"
              pointer-events="none"
            >
              Loading Shape
            </text>
        <% end %>
      <% else %>
        <%= case style_or_default(@layer, :background_url) do %>
          <% nil -> %>
            <rect
              id={"fallback-#{@layer.box.id}"}
              x={@layer.box.position_x}
              y={@layer.box.position_y}
              width={@layer.box.width}
              height={@layer.box.height}
              pointer-events="all"
            >
            </rect>
          <% str -> %>
            <rect
              id={"fallback-#{@layer.box.id}"}
              fill="none"
              pointer-events="all"
              stroke="red"
              stroke-width="5"
              x={@layer.box.position_x}
              y={@layer.box.position_y}
              width={@layer.box.width}
              height={@layer.box.height}
            >
            </rect>
            <image
              x={@layer.box.position_x}
              y={@layer.box.position_y}
              width={@layer.box.width}
              height={@layer.box.height}
              xlink:href={str}
              pointer-events="none"
            />
        <% end %>
      <% end %>

      <%= if @selected do %>
        <g>
          <rect
            cursor="move"
            phx-hook="RnwBoxDragger"
            rnw-layer-id={@layer.id}
            stroke="#33aaff"
            stroke-linejoin="round"
            stroke-linecap="round"
            opacity="0.8"
            stroke-width="4"
            fill="#33aaff"
            fill-opacity="0.4"
            id={"box-select-#{@layer.box.id}"}
            x={@layer.box.position_x}
            y={@layer.box.position_y}
            width={@layer.box.width}
            height={@layer.box.height}
            stroke-dasharray="1"
          >
          </rect>

          <circle
            stroke="transparent"
            stroke-width="10"
            cursor="move"
            phx-hook="RnwBoxResizeDragger"
            rnw-layer-id={"#{@layer.id}"}
            id={"box-resize-#{@layer.box.id}"}
            cx={@layer.box.position_x + @layer.box.width + 5}
            cy={@layer.box.position_y + @layer.box.height + 5}
            r="5"
            fill="green"
          >
          </circle>
        </g>
      <% end %>
    </g>
    """
  end

  defp pie_path(box, start_angle, end_angle) do
    cos_start = :math.cos(:math.pi() / 180 * (start_angle || 0))
    sin_start = :math.sin(:math.pi() / 180 * (start_angle || 0))
    cos_end = :math.cos(:math.pi() / 180 * (end_angle || 180))
    sin_end = :math.sin(:math.pi() / 180 * (end_angle || 180))

    dot = cos_start * cos_end + sin_start * sin_end
    det = cos_start * sin_end - sin_start * cos_end
    angle_diff = :math.atan2(-det, -dot) * 180 / :math.pi() + 180

    "M #{box.position_x + box.width / 2}, #{box.position_y + box.height / 2} L #{box.position_x + box.width / 2 + cos_start * box.width / 2},
       #{box.position_y + box.height / 2 - sin_start * box.height / 2}
      A #{box.width / 2} #{box.height / 2} 0 #{if(angle_diff < 180, do: ~c"0 0", else: ~c"1 0")} #{box.position_x + box.width / 2 + cos_end * box.width / 2},
       #{box.position_y + box.height / 2 - sin_end * box.height / 2} z"
  end

  defp style_or_default(%{:style => nil}, style_key) do
    default_style(style_key)
  end

  defp style_or_default(%{:style => style}, style_key) do
    with %{^style_key => value} <- style do
      value || default_style(style_key)
    else
      _ -> default_style(style_key)
    end
  end

  defp default_style(:background_color), do: "#70DB93"
  defp default_style(_style_key), do: nil
end
