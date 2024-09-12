defmodule RenewCollabWeb.HierarchyLayerEdgeComponent do
  use Phoenix.LiveComponent
  alias RenewCollab.Symbol

  @impl true
  def render(assigns) do
    ~H"""
    <g>
      <path 
            stroke={@layer.edge.style.stroke_color}
            stroke-width={@layer.edge.style.stroke_width}
            stroke-line-join={@layer.edge.style.stroke_join}
            stroke-line-cap={@layer.edge.style.stroke_cap}
            stroke-dasharray={@layer.edge.style.stroke_dash_array} stroke="black" d={edge_path(@layer.edge)} fill="none"></path>
            <%= if @layer.edge.style.source_tip_symbol_shape_id do %>
            <g  id={"edge-#{@layer.edge.id}-source-tip"} transform={"rotate(#{edge_angle(:source, @layer.edge)} #{@layer.edge.source_x} #{@layer.edge.source_y})"}>
              <%!-- <rect opacity="0.5" fill="red" x={@layer.edge.source_x - 20} y={@layer.edge.source_y - 5} width="20" height="10" /> --%>
               <%= for path <- @symbols[@layer.edge.style.source_tip_symbol_shape_id].paths do %> 
                  <path stroke={path.stroke_color} fill={path.fill_color} d={Symbol.build_symbol_path(%{
                    position_x: @layer.edge.source_x - (Integer.parse(@layer.edge.style.stroke_width) |> elem(0)),
                    position_y: @layer.edge.source_y - (Integer.parse(@layer.edge.style.stroke_width) |> elem(0)),
                    width: (Integer.parse(@layer.edge.style.stroke_width) |> elem(0))*2,
                    height: (Integer.parse(@layer.edge.style.stroke_width) |> elem(0))*2,
                }, path)} fill-rule="evenodd" />
                <% end %>
            </g>
            <% end %>
            <%= if @layer.edge.style.target_tip_symbol_shape_id do %>
            <g  id={"edge-#{@layer.edge.id}-target-tip"} transform={"rotate(#{edge_angle(:target, @layer.edge)} #{@layer.edge.target_x} #{@layer.edge.target_y})"}>
              <%!-- <rect opacity="0.5" fill="red" x={@layer.edge.target_x - 20} y={@layer.edge.target_y - 5} width="20" height="10" /> --%>

               <%= for path <- @symbols[@layer.edge.style.target_tip_symbol_shape_id].paths do %> 
                  <path stroke={path.stroke_color} fill={path.fill_color} d={Symbol.build_symbol_path(%{
                    position_x: @layer.edge.target_x - (Integer.parse(@layer.edge.style.stroke_width) |> elem(0)),
                    position_y: @layer.edge.target_y - (Integer.parse(@layer.edge.style.stroke_width) |> elem(0)),
                    width: (Integer.parse(@layer.edge.style.stroke_width) |> elem(0))*2,
                    height: (Integer.parse(@layer.edge.style.stroke_width) |> elem(0))*2,
                }, path)}   fill-rule="evenodd" />
                <% end %>
            </g>
            <% end %>


      <%= if @selected do %>
        <path stroke="magenta" stroke-width="8" d={edge_path(@layer.edge)} fill="none" id={"edge-select-#{@layer.edge.id}"}></path>
      <% end %>
      </g>
    """
  end

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
