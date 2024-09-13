defmodule RenewCollabWeb.HierarchyLayerBoxComponent do
  use Phoenix.LiveComponent
  alias RenewCollab.Symbol

  @impl true
  def render(assigns) do
    ~H"""
    <g id={"box-#{@layer.box.id}"} stroke-dasharray={style_or_default(@layer, :border_dash_array)} stroke-width={style_or_default(@layer, :border_width)} fill={style_or_default(@layer, :background_color)} stroke={style_or_default(@layer, :border_color)} opacity={style_or_default(@layer, :opacity)} >
      <%= if @layer.box.symbol_shape_id do %>
       <%= case @layer.box.symbol_shape.name do %>
        <% "rect-round" -> %>
              <rect  id={"roundrect-#{@layer.box.id}"} rx={@layer.box.symbol_shape_attributes["rx"] / 2}  ry={@layer.box.symbol_shape_attributes["ry"]  /2} x={@layer.box.position_x} y={@layer.box.position_y} width={@layer.box.width} height={@layer.box.height}></rect>
        <% "pie" -> %>
              
            <path  id={"pie-#{@layer.box.id}"} d={pie_path(@layer.box, @layer.box.symbol_shape_attributes["start_angle"], @layer.box.symbol_shape_attributes["end_angle"])} fill-rule="evenodd" />
        <% _ -> %>
        <g id={"symbol-#{@layer.box.id}-#{@layer.box.symbol_shape_id}"}>
          
            <%= for path <- @symbols[@layer.box.symbol_shape_id].paths do %> 
              <path stroke={path.stroke_color} fill={path.fill_color} d={Symbol.build_symbol_path(@layer.box, path)} 
        fill-rule="evenodd" />
            <% end %>
        </g>
          <% end %>
     
      <% else %>
            <rect  id={"fallback-#{@layer.box.id}"} x={@layer.box.position_x} y={@layer.box.position_y} width={@layer.box.width} height={@layer.box.height}></rect>
      <% end %>

      <%= if @selected do %>
        <rect stroke="magenta" stroke-width="4" fill="magenta" fill-opacity="0.2" id={"box-select-#{@layer.box.id}"} x={@layer.box.position_x} y={@layer.box.position_y} width={@layer.box.width} height={@layer.box.height}></rect>
      <% end %>
    </g>
    """
  end

  defp pie_path(box, start_angle, end_angle) do
    cos_start = :math.cos(:math.pi() / 180 * start_angle)
    sin_start = :math.sin(:math.pi() / 180 * start_angle)
    cos_end = :math.cos(:math.pi() / 180 * end_angle)
    sin_end = :math.sin(:math.pi() / 180 * end_angle)

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
      value
    else
      _ -> default_style(style_key)
    end
  end

  defp default_style(style_key), do: nil
end
