defmodule RenewCollabWeb.HierarchyLayerTextComponent do
  use Phoenix.LiveComponent
  alias RenewCollab.Symbol

  @impl true
  def render(assigns) do
    ~H"""
        <g opacity={style_or_default(@layer, :opacity)}  id={"#{@layer.text.id}-wrapper"}>
          <g data-background-box id={"#{@layer.text.id}-outline-box-container"} stroke-dasharray={style_or_default(@layer, :border_dash_array)} stroke-width={style_or_default(@layer, :border_width)} fill={style_or_default(@layer, :background_color)} stroke={style_or_default(@layer, :border_color)} >
            <rect id={"#{@layer.text.id}-outline-box"} phx-update="ignore" x={@layer.text.position_x} y={@layer.text.position_y} width="0" height="0"></rect>
          </g>
          <text 
            cursor="default"
            fill={style_or_default(@layer.text, :text_color)}
            data-text-anchor={text_anchor(style_or_default(@layer.text, :alignment))}
            font-weight={if(style_or_default(@layer.text, :bold), do: "bold", else: "normal")}
            font-style={if(style_or_default(@layer.text, :italic), do: "italic", else: "normal")}
            font-size={style_or_default(@layer.text, :font_size)} font-family={style_or_default(@layer.text, :font_family)} 
            id={"text-#{@layer.text.id}"} 
            phx-hook="ResizeRenewText" 
            x={@layer.text.position_x} 
            y={@layer.text.position_y}>
            <%= for {{line, format}, li} <- @layer.text.body |> String.split("\n") |> filter_blank_lines(style_or_default(@layer.text, :blank_lines)) |> Enum.map(&format_line(style_or_default(@layer.text, :rich), &1)) |> Enum.with_index() do %>
              <%= if String.trim(line) != "" do %>
              <tspan 
            {if(style_or_default(@layer.text, :underline), do: ["text-decoration": "underline"], else: [])} {format} {if(li==0 and style_or_default(@layer.text, :rich), do: ["font-weight": "bold"], else: [])} x={@layer.text.position_x} {[dy: if(li>0, do: "1.2em", else: "1em")]}><%= line %></tspan>
              <% else %>
              <tspan fill="transparent" stroke="transparent" text-decoration="none" x={@layer.text.position_x} {[dy: if(li>0, do: "1.2em", else: "1em")]} visibility="hidden">&nbsp;</tspan>
              <% end %>              
            <% end %>
          </text>

          <%= if @selected do %>
          <g cursor="move" phx-hook="RnwTextDragger" rnw-layer-id={@layer.id} id={"#{@layer.text.id}-outline-box-selection-dragger"}>
            <g data-background-box id={"#{@layer.text.id}-outline-box-selection-container"}>
              <rect fill="#33aaff" fill-opacity="0.3" opacity="0.8" id={"#{@layer.text.id}-outline-box-selection"} phx-update="ignore" x={@layer.text.position_x} y={@layer.text.position_y} width="0" height="0"></rect>
            </g>

            <text 
            pointer-events="none"
            cursor="default"
            stroke="#33aaff"
            stroke-linejoin="round" 
            stroke-linecap="round"
            opacity="0.3"
            stroke-width="5"
            fill="none"
            phx-hook="ResizeRenewText" 
            data-text-anchor={text_anchor(style_or_default(@layer.text, :alignment))}
            font-weight={if(style_or_default(@layer.text, :bold), do: "bold", else: "normal")}
            font-style={if(style_or_default(@layer.text, :italic), do: "italic", else: "normal")}
            font-size={style_or_default(@layer.text, :font_size)} font-family={style_or_default(@layer.text, :font_family)} 
            id={"text-select-#{@layer.text.id}"} 
            x={@layer.text.position_x} 
            y={@layer.text.position_y}>
            <%= for {{line, format}, li} <- @layer.text.body |> String.split("\n") |> filter_blank_lines(style_or_default(@layer.text, :blank_lines)) |> Enum.map(&format_line(style_or_default(@layer.text, :rich), &1)) |> Enum.with_index() do %>
              <%= if String.trim(line) != "" do %>
              <tspan {if(style_or_default(@layer.text, :underline), do: ["text-decoration": "underline"], else: [])} {format} {if(li==0 and style_or_default(@layer.text, :rich), do: ["font-weight": "bold"], else: [])} x={@layer.text.position_x} {[dy: if(li>0, do: "1.2em", else: "1em")]}><%= line %></tspan>
              <% else %>
              <tspan fill="transparent" stroke="transparent" text-decoration="none" visibility="hidden" x={@layer.text.position_x} {[dy: if(li>0, do: "1.2em", else: "1em")]}>&nbsp;</tspan>
              <% end %>              <% end %>
          </text>
      </g>
          <% end %>
        </g>
    """
  end

  defp text_anchor(:left), do: "start"
  defp text_anchor(:center), do: "middle"
  defp text_anchor(:right), do: "end"
  defp text_anchor(nil), do: "start"

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

  defp default_style(:alignment), do: :left
  defp default_style(:blank_lines), do: false
  defp default_style(:background_color), do: "transparent"
  defp default_style(style_key), do: nil

  defp format_line(true, <<"_", rest::binary>>), do: {rest, ["text-decoration": "underline"]}
  defp format_line(true, <<"\\", rest::binary>>), do: {rest, ["font-style": "italic"]}

  defp format_line(_, line), do: {line, []}

  defp filter_blank_lines(lines, true), do: lines

  defp filter_blank_lines(lines, false),
    do: Enum.filter(lines, fn line -> String.trim(line) |> String.length() > 0 end)
end
