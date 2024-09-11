defmodule RenewCollabWeb.LiveDocument do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollab.Renew
  alias RenewCollab.Symbol

  def mount(%{"id" => id}, _session, socket) do
    socket =
      socket
      |> assign(:document, Renew.get_document_with_elements!(id))
      |> assign(:symbols, Symbol.list_shapes() |> Enum.map(fn s -> {s.id, s} end) |> Map.new())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid;width: 100%; grid-template-rows: auto 1fr;">
      <.link href={~p"/live/documents"}>Back</.link>
      <h2><%= @document.name %></h2>
      <svg viewBox={viewbox(@document)} style="display: block;" width="1000">
        <%= for {layer, i} <- @document.layers |> Enum.with_index do %> 
          <%= if not layer.hidden  do %>
          <%= if layer.text do %>
          <g opacity={layer.style.opacity}>
            <rect stroke-dasharray={layer.style.border_dash_array} stroke-width={layer.style.border_width} fill={layer.style.background_color} stroke={layer.style.border_color} id={"#{layer.text.id}-outline-box"} x={layer.text.position_x} y={layer.text.position_y} width={0} height={0}></rect>
            <text 
              fill={layer.text.style.text_color}
              font-weight={if(layer.text.style.bold, do: "bold", else: "normal")}
              font-style={if(layer.text.style.italic, do: "italic", else: "normal")}
              text-decoration={if(layer.text.style.underline, do: "underline", else: "none")}
              font-size={layer.text.style.font_size} font-family={layer.text.style.font_family} id={"#{layer.text.id}"} phx-hook="ResizeRenewText" x={layer.text.position_x} y={layer.text.position_y}>
              <%= for line <- layer.text.body |> String.split("\n") do %>
                <tspan x={layer.text.position_x} dy="1em"><%= line %></tspan>
              <% end %>
            </text>
          </g>
          <% end %>

          <%= if layer.box do %>
          <g stroke-dasharray={layer.style.border_dash_array} stroke-width={layer.style.border_width} fill={layer.style.background_color} stroke={layer.style.border_color} opacity={layer.style.opacity} >
          <%= if layer.box.symbol_shape_id do %>
          <%= for path <- @symbols[layer.box.symbol_shape_id].paths do %> 
            <path stroke={path.stroke_color} fill={path.fill_color} d={Symbol.build_symbol_path(layer.box, path)} />
          <% end %>
          <% else %>
          <rect x={layer.box.position_x} y={layer.box.position_y} width={layer.box.width} height={layer.box.height}></rect>
          <% end %>
          </g>
          <% end %>
          
          <%= if layer.edge do %>
            <path 
            stroke={layer.edge.style.stroke_color}
            stroke-width={layer.edge.style.stroke_width}
            stroke-line-join={layer.edge.style.stroke_join}
            stroke-line-cap={layer.edge.style.stroke_cap}
            stroke-dasharray={layer.edge.style.stroke_dash_array} stroke="black" d={edge_path(layer.edge)} fill="none"></path>
          <% end %>
          <% end%>
        <% end %>
      </svg>
    </div>
    """
  end

  defp edge_path(edge) do
    waypoints =
      edge.waypoints
      |> Enum.map(fn %{position_x: x, position_y: y} -> "L #{x} #{y}" end)
      |> Enum.join(" ")

    "M #{edge.source_x} #{edge.source_y} #{waypoints} L #{edge.target_x} #{edge.target_y}"
  end

  defp viewbox(document) do
    min_viewbox_x =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.reduce(0, fn
        nil, acc -> acc
        b, acc -> min(acc, b.position_x)
      end)

    min_viewbox_y =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.reduce(0, fn
        nil, acc -> acc
        b, acc -> min(acc, b.position_y)
      end)

    max_viewbox_x =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.reduce(0, fn
        nil, acc -> acc
        b, acc -> max(acc, b.position_x + b.width)
      end)

    max_viewbox_y =
      document.layers
      |> Enum.map(& &1.box)
      |> Enum.reduce(0, fn
        nil, acc -> acc
        b, acc -> max(acc, b.position_y + b.height)
      end)

    [min_viewbox_x, min_viewbox_y, max_viewbox_x, max_viewbox_y] |> Enum.join(" ")
  end
end
