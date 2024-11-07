defmodule RenewCollabWeb.HierarchyLayerEdgeComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <g>
      <g
        opacity={style_or_default(@layer, :opacity)}
        stroke={style_or_default(@layer.edge, :stroke_color)}
        stroke-width={style_or_default(@layer.edge, :stroke_width)}
        stroke-linejoin={style_or_default(@layer.edge, :stroke_join)}
        stroke-linecap={style_or_default(@layer.edge, :stroke_cap)}
      >
        <path
          stroke-dasharray={style_or_default(@layer.edge, :stroke_dash_array)}
          d={edge_path(@layer.edge, style_or_default(@layer.edge, :smoothness))}
          fill="none"
        >
        </path>

        <%= if style_or_default(@layer.edge, :source_tip_symbol_shape_id) do %>
          <g
            fill={style_or_default(@layer, :background_color)}
            id={"edge-#{@layer.edge.id}-source-tip"}
            transform={"rotate(#{edge_angle(:source, @layer.edge)} #{@layer.edge.source_x} #{@layer.edge.source_y})"}
          >
            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
              <%!-- <rect opacity="0.5" fill="red" x={@layer.edge.source_x - 20} y={@layer.edge.source_y - 5} width="20" height="10" /> --%>
              <%= for path <- symbols[style_or_default(@layer.edge, :source_tip_symbol_shape_id)].paths do %>
                <path
                  stroke={path.stroke_color}
                  fill={path.fill_color}
                  d={
                    RenewexIconset.Builder.build_symbol_path(
                      %{
                        position_x:
                          @layer.edge.source_x -
                            style_or_default(@layer.edge, :stroke_width),
                        position_y:
                          @layer.edge.source_y -
                            style_or_default(@layer.edge, :stroke_width),
                        width: style_or_default(@layer.edge, :stroke_width) * 2,
                        height: style_or_default(@layer.edge, :stroke_width) * 2
                      },
                      path
                    )
                  }
                  fill-rule="evenodd"
                />
              <% end %>
              <% else _ -> %>
            <% end %>
          </g>
        <% end %>

        <%= if style_or_default(@layer.edge, :target_tip_symbol_shape_id) do %>
          <g
            fill={style_or_default(@layer, :background_color)}
            id={"edge-#{@layer.edge.id}-target-tip"}
            transform={"rotate(#{edge_angle(:target, @layer.edge)} #{@layer.edge.target_x} #{@layer.edge.target_y})"}
          >
            <%!-- <rect opacity="0.5" fill="red" x={@layer.edge.target_x - 20} y={@layer.edge.target_y - 5} width="20" height="10" /> --%>
            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: symbols} <- @symbols do %>
              <%= for path <- symbols[style_or_default(@layer.edge, :target_tip_symbol_shape_id)].paths do %>
                <path
                  stroke={path.stroke_color}
                  fill={path.fill_color}
                  d={
                    RenewexIconset.Builder.build_symbol_path(
                      %{
                        position_x:
                          @layer.edge.target_x -
                            style_or_default(@layer.edge, :stroke_width),
                        position_y:
                          @layer.edge.target_y -
                            style_or_default(@layer.edge, :stroke_width),
                        width: style_or_default(@layer.edge, :stroke_width) * 2,
                        height: style_or_default(@layer.edge, :stroke_width) * 2
                      },
                      path
                    )
                  }
                  fill-rule="evenodd"
                />
              <% end %>
              <% else _ -> %>
            <% end %>
          </g>
        <% end %>
      </g>

      <path
        stroke="transparent"
        stroke-linejoin="round"
        stroke-linecap="round"
        stroke-width="8"
        d={edge_path(@layer.edge, style_or_default(@layer.edge, :smoothness))}
        fill="none"
        id={"edge-hitarea-#{@layer.edge.id}"}
      >
      </path>

      <%= if @selected do %>
        <path
          stroke="#000"
          stroke-dasharray="5 5"
          stroke-linejoin="round"
          stroke-linecap="round"
          opacity="0.6"
          stroke-width="1"
          d={edge_path(@layer.edge, :linear)}
          fill="none"
          id={"edge-support-#{@layer.edge.id}"}
        >
        </path>

        <path
          stroke="#33aaff"
          stroke-linejoin="round"
          stroke-linecap="round"
          opacity="0.8"
          stroke-width="8"
          d={edge_path(@layer.edge, style_or_default(@layer.edge, :smoothness))}
          fill="none"
          id={"edge-select-#{@layer.edge.id}"}
        >
        </path>

        <%= for w <- @layer.edge.waypoints do %>
          <circle
            stroke="transparent"
            stroke-width="10"
            cursor="move"
            phx-hook="RnwWaypointDragger"
            rnw-layer-id={"#{@layer.id}"}
            rnw-waypoint-id={"#{w.id}"}
            id={"waypoint-#{w.id}"}
            cx={w.position_x}
            cy={w.position_y}
            r="5"
            fill="#ff4400"
          >
          </circle>
        <% end %>

        <%= for [w1,w2] <- [%{id: nil, position_x: @layer.edge.source_x, position_y: @layer.edge.source_y}] |> Enum.concat(@layer.edge.waypoints) |> Enum.chunk_every(2, 1, [%{position_x: @layer.edge.target_x, position_y: @layer.edge.target_y}]) do %>
          <circle
            stroke="transparent"
            stroke-width="10"
            cursor="move"
            phx-hook="RnwWaypointCreator"
            rnw-layer-id={"#{@layer.id}"}
            rnw-waypoint-id={w1.id}
            id={"waypoint-after-#{w1.id}"}
            cx={(w1.position_x + w2.position_x) / 2}
            cy={(w1.position_y + w2.position_y) / 2}
            r="5"
            fill="#ff8800"
          >
          </circle>
        <% end %>

        <%= if @layer.edge.target_bond do %>
          <circle
            cursor="pointer"
            rnw-layer-id={"#{@layer.id}"}
            rnw-edge-side="target"
            id={"detach-#{@layer.edge.id}-target"}
            cx={@layer.edge.target_x - 10 * :math.cos(edge_angle(:target, @layer.edge) / 180 * 3.14)}
            cy={@layer.edge.target_y - 10 * :math.sin(edge_angle(:target, @layer.edge) / 180 * 3.14)}
            r="5"
            fill="darkred"
            phx-click="detach-bond"
            phx-value-id={@layer.edge.target_bond.id}
          >
          </circle>
        <% else %>
          <circle
            stroke="transparent"
            stroke-width="10"
            cursor="move"
            phx-hook="RnwEdgeDragger"
            rnw-layer-id={"#{@layer.id}"}
            rnw-edge-side="target"
            id={"waypoint-#{@layer.edge.id}-target"}
            cx={@layer.edge.target_x}
            cy={@layer.edge.target_y}
            r="5"
            fill="blue"
          >
          </circle>

          <circle
            cursor="alias"
            rnw-layer-id={"#{@layer.id}"}
            rnw-edge-id={"#{@layer.edge.id}"}
            rnw-edge-side="target"
            phx-hook="RnwEdgeAttacher"
            id={"attach-#{@layer.edge.id}-target"}
            cx={@layer.edge.target_x - 10 * :math.cos(edge_angle(:target, @layer.edge) / 180 * 3.14)}
            cy={@layer.edge.target_y - 10 * :math.sin(edge_angle(:target, @layer.edge) / 180 * 3.14)}
            r="5"
            fill="cyan"
          >
          </circle>
        <% end %>

        <%= if @layer.edge.source_bond do %>
          <circle
            cursor="pointer"
            rnw-layer-id={"#{@layer.id}"}
            rnw-edge-side="source"
            id={"detach-#{@layer.edge.id}-source"}
            cx={@layer.edge.source_x - 10 * :math.cos(edge_angle(:source, @layer.edge) / 180 * 3.14)}
            cy={@layer.edge.source_y - 10 * :math.sin(edge_angle(:source, @layer.edge) / 180 * 3.14)}
            r="5"
            fill="darkred"
            phx-click="detach-bond"
            phx-value-id={@layer.edge.source_bond.id}
          >
          </circle>
        <% else %>
          <circle
            stroke="transparent"
            stroke-width="10"
            cursor="move"
            phx-hook="RnwEdgeDragger"
            rnw-layer-id={"#{@layer.id}"}
            rnw-edge-side="source"
            id={"waypoint-#{@layer.edge.id}-source"}
            cx={@layer.edge.source_x}
            cy={@layer.edge.source_y}
            r="5"
            fill="blue"
          >
          </circle>

          <circle
            cursor="alias"
            rnw-layer-id={"#{@layer.id}"}
            rnw-edge-id={"#{@layer.edge.id}"}
            rnw-edge-side="source"
            phx-hook="RnwEdgeAttacher"
            id={"attach-#{@layer.edge.id}-source"}
            cx={@layer.edge.source_x - 10 * :math.cos(edge_angle(:source, @layer.edge) / 180 * 3.14)}
            cy={@layer.edge.source_y - 10 * :math.sin(edge_angle(:source, @layer.edge) / 180 * 3.14)}
            r="5"
            fill="cyan"
          >
          </circle>
        <% end %>
      <% end %>
    </g>
    """
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

  defp default_style(:smoothness), do: :linear
  defp default_style(:stroke_color), do: :black
  defp default_style(_style_key), do: nil

  defp edge_path(edge, :linear) do
    waypoints =
      edge.waypoints
      |> Enum.map(fn %{position_x: x, position_y: y} -> "L #{x} #{y}" end)
      |> Enum.join(" ")

    "M #{edge.source_x} #{edge.source_y} #{waypoints} L #{edge.target_x} #{edge.target_y}"
  end

  defp edge_path(edge, :autobezier) do
    case edge.waypoints do
      [] ->
        "M #{edge.source_x} #{edge.source_y} L #{edge.target_x} #{edge.target_y}"

      [w] ->
        "M #{edge.source_x} #{edge.source_y}  Q #{w.position_x} #{w.position_y} #{edge.target_x} #{edge.target_y}"

      more ->
        waypoints =
          more
          |> Enum.map(fn %{position_x: x, position_y: y} -> {x, y} end)
          |> then(&Enum.concat([{edge.source_x, edge.source_y}], &1))
          |> Enum.chunk_every(2, 1, :discard)
          |> Enum.drop(1)
          |> Enum.map(fn [{x1, y1}, {x2, y2}] ->
            "Q #{x1} #{y1} #{(x2 + x1) / 2} #{(y2 + y1) / 2}"
          end)
          |> Enum.join(" ")

        "M #{edge.source_x} #{edge.source_y} #{waypoints} T #{edge.target_x} #{edge.target_y}"
    end
  end

  defp edge_angle(:source, edge) do
    %{position_x: x, position_y: y} =
      List.first(edge.waypoints, %{position_x: edge.target_x, position_y: edge.target_y})

    :math.atan2(edge.source_y - y, edge.source_x - x) * 180 / :math.pi()
  end

  defp edge_angle(:target, edge) do
    %{position_x: x, position_y: y} =
      List.last(edge.waypoints, %{position_x: edge.source_x, position_y: edge.source_y})

    :math.atan2(edge.target_y - y, edge.target_x - x) * 180 / :math.pi()
  end
end
