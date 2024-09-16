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
            cursor="default"
            fill={style_or_default(@layer.text, :text_color)}
            data-text-anchor={text_anchor(style_or_default(@layer.text, :alignment))}
            font-weight={if(style_or_default(@layer.text, :bold), do: "bold", else: "normal")}
            font-style={if(style_or_default(@layer.text, :italic), do: "italic", else: "normal")}
            text-decoration={if(style_or_default(@layer.text, :underline), do: "underline", else: "none")}
            font-size={style_or_default(@layer.text, :font_size)} font-family={style_or_default(@layer.text, :font_family)} 
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
            cursor="default"
            stroke="magenta"
            stroke-linejoin="round" 
            stroke-linecap="round"
            opacity="0.3"
            stroke-width="5"
            fill="none"
            phx-hook="ResizeRenewText" 
            data-text-anchor={text_anchor(style_or_default(@layer.text, :alignment))}
            font-weight={if(style_or_default(@layer.text, :bold), do: "bold", else: "normal")}
            font-style={if(style_or_default(@layer.text, :italic), do: "italic", else: "normal")}
            text-decoration={if(style_or_default(@layer.text, :underline), do: "underline", else: "none")}
            font-size={style_or_default(@layer.text, :font_size)} font-family={style_or_default(@layer.text, :font_family)} 
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
