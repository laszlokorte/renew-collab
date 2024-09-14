defmodule RenewCollabWeb.HierarchyLayerEdgeComponent do
  use Phoenix.LiveComponent
  alias RenewCollab.Symbol

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
      <path stroke-dasharray={style_or_default(@layer.edge, :stroke_dash_array)} d={edge_path(@layer.edge)} fill="none"></path>
            
            <%= if style_or_default(@layer.edge, :source_tip_symbol_shape_id) do %>
            <g fill={style_or_default(@layer, :background_color)}  id={"edge-#{@layer.edge.id}-source-tip"} transform={"rotate(#{edge_angle(:source, @layer.edge)} #{@layer.edge.source_x} #{@layer.edge.source_y})"}>
              <%!-- <rect opacity="0.5" fill="red" x={@layer.edge.source_x - 20} y={@layer.edge.source_y - 5} width="20" height="10" /> --%>
               <%= for path <- @symbols[style_or_default(@layer.edge, :source_tip_symbol_shape_id)].paths do %> 
                  <path stroke={path.stroke_color} fill={path.fill_color} d={Symbol.build_symbol_path(%{
                    position_x: @layer.edge.source_x - (Integer.parse(style_or_default(@layer.edge, :stroke_width)) |> elem(0)),
                    position_y: @layer.edge.source_y - (Integer.parse(style_or_default(@layer.edge, :stroke_width)) |> elem(0)),
                    width: (Integer.parse(style_or_default(@layer.edge, :stroke_width)) |> elem(0))*2,
                    height: (Integer.parse(style_or_default(@layer.edge, :stroke_width)) |> elem(0))*2,
                }, path)} fill-rule="evenodd" />
                <% end %>
            </g>
            <% end %>

            <%= if style_or_default(@layer.edge, :target_tip_symbol_shape_id) do %>
            <g fill={style_or_default(@layer, :background_color)}  id={"edge-#{@layer.edge.id}-target-tip"} transform={"rotate(#{edge_angle(:target, @layer.edge)} #{@layer.edge.target_x} #{@layer.edge.target_y})"}>
              <%!-- <rect opacity="0.5" fill="red" x={@layer.edge.target_x - 20} y={@layer.edge.target_y - 5} width="20" height="10" /> --%>

               <%= for path <- @symbols[style_or_default(@layer.edge, :target_tip_symbol_shape_id)].paths do %> 
                  <path stroke={path.stroke_color} fill={path.fill_color} d={Symbol.build_symbol_path(%{
                    position_x: @layer.edge.target_x - (Integer.parse(style_or_default(@layer.edge, :stroke_width)) |> elem(0)),
                    position_y: @layer.edge.target_y - (Integer.parse(style_or_default(@layer.edge, :stroke_width)) |> elem(0)),
                    width: (Integer.parse(style_or_default(@layer.edge, :stroke_width)) |> elem(0))*2,
                    height: (Integer.parse(style_or_default(@layer.edge, :stroke_width)) |> elem(0))*2,
                }, path)}   fill-rule="evenodd" />
                <% end %>
            </g>
            <% end %>

      </g>


      <%= if @selected do %>
        <path stroke="magenta" stroke-linejoin="round" stroke-linecap="round"  opacity="0.3" stroke-width="8" d={edge_path(@layer.edge)} fill="none" id={"edge-select-#{@layer.edge.id}"}></path>

        <%= for w <- @layer.edge.waypoints do %>
          <circle cx={w.position_x} cy={w.position_y} r="5" fill="magenta"></circle>
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
      value
    else
      _ -> default_style(style_key)
    end
  end

  defp default_style(style_key), do: nil

  defp edge_path(edge) do
    waypoints =
      edge.waypoints
      |> Enum.map(fn %{position_x: x, position_y: y} -> "L #{x} #{y}" end)
      |> Enum.join(" ")

    "M #{edge.source_x} #{edge.source_y} #{waypoints} L #{edge.target_x} #{edge.target_y}"
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
