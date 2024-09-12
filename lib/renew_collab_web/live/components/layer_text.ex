defmodule RenewCollabWeb.HierarchyLayerTextComponent do
  use Phoenix.LiveComponent
  alias RenewCollab.Symbol

  @impl true
  def render(assigns) do
    ~H"""
        <g opacity={@layer.style.opacity}  id={"#{@layer.text.id}-wrapper"}>
          <g data-background-box id={"#{@layer.text.id}-outline-box-container"} stroke-dasharray={@layer.style.border_dash_array} stroke-width={@layer.style.border_width} fill={@layer.style.background_color} stroke={@layer.style.border_color} >
            <rect id={"#{@layer.text.id}-outline-box"} phx-update="ignore" x={@layer.text.position_x} y={@layer.text.position_y} width="0" height="0"></rect>
          </g>
          <text 
            fill={@layer.text.style.text_color}
            data-text-anchor={text_anchor(@layer.text.style.alignment)}
            font-weight={if(@layer.text.style.bold, do: "bold", else: "normal")}
            font-style={if(@layer.text.style.italic, do: "italic", else: "normal")}
            text-decoration={if(@layer.text.style.underline, do: "underline", else: "none")}
            font-size={@layer.text.style.font_size} font-family={@layer.text.style.font_family} 
            id={"text-#{@layer.text.id}"} 
            phx-hook="ResizeRenewText" 
            x={@layer.text.position_x} 
            y={@layer.text.position_y}>
            <%= for line <- @layer.text.body |> String.split("\n") do %>
              <tspan x={@layer.text.position_x} dy="1.2em"><%= line %></tspan>
            <% end %>
          </text>

          <%= if @selected do %>
            <text 
            stroke="magenta"
            stroke-width="5"
            fill="none"
            phx-hook="ResizeRenewText" 
            data-text-anchor={text_anchor(@layer.text.style.alignment)}
            font-weight={if(@layer.text.style.bold, do: "bold", else: "normal")}
            font-style={if(@layer.text.style.italic, do: "italic", else: "normal")}
            text-decoration={if(@layer.text.style.underline, do: "underline", else: "none")}
            font-size={@layer.text.style.font_size} font-family={@layer.text.style.font_family} 
            id={"text-select-#{@layer.text.id}"} 
            x={@layer.text.position_x} 
            y={@layer.text.position_y}>
            <%= for line <- @layer.text.body |> String.split("\n") do %>
              <tspan x={@layer.text.position_x} dy="1.2em"><%= line %></tspan>
            <% end %>
          </text>
          <% end %>
        </g>
    """
  end

  defp text_anchor(:left), do: "start"
  defp text_anchor(:center), do: "middle"
  defp text_anchor(:right), do: "end"
end
