defmodule RenewCollabWeb.HierarchyRowComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <tr id={"layer-list-item-#{@layer.id}"} bgcolor={if(@selected, do: "#ffaaff", else: "white")}>
        <td width="20" align="center" style="cursor:pointer;" phx-click="toggle_visible" phx-value-id={@layer.id}><%= if @layer.hidden do %><% else %>👁<% end %></td>
        <td width="20" align="center"><%= if @layer.box do %>☐<% end %></td>
        <td width="20" align="center"><%= if @layer.text do %>T<% end %></td>
        <td width="20" align="center"><%= if @layer.edge do %>⭝<% end %>
          <%= if not (is_nil(@layer.edge) or is_nil(@layer.edge.style)) do %><%= @layer.edge.style.source_tip_symbol_shape_id %><% end %>
        </td>
        <td width="20" align="right"><%= @layer.z_index %></td>
        <td style={"cursor: pointer; padding-left: #{2*@depth}em"} phx-click="select_layer" phx-value-id={@layer.id}><%= @layer.id %><br><small><code><%= @layer.semantic_tag %></code></small></td>
      </tr>
    """
  end
end
