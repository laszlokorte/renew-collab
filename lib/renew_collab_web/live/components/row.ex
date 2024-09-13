defmodule RenewCollabWeb.HierarchyRowComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <tr id={"layer-list-item-#{@layer.id}"} bgcolor={if(@selected, do: "#ffaaff", else: "white")}>
        <td width="20" align="center" style="cursor:pointer;" phx-click="toggle_visible" phx-value-id={@layer.id}><%= if @layer.hidden do %><% else %>👁<% end %></td>
        <td width="20" align="center"><%= if @layer.box do %>☐<% end %></td>
        <td width="20" align="center"><%= if @layer.text do %>T<% end %></td>
        <td width="20" align="center">
          <%= if not (is_nil(@layer.edge) or is_nil(@layer.edge.style)) do %>
          <%= if @layer.edge.style.source_tip_symbol_shape_id do %>
            &lt;
          <% end %>
          <% end %>
          <%= if @layer.edge do %>&mdash;<% end %>
          <%= if not (is_nil(@layer.edge) or is_nil(@layer.edge.style)) do %>
          <%= if @layer.edge.style.target_tip_symbol_shape_id do %>
            &gt;
          <% end %>
          <% end %>
        </td>
        <td width="20" align="right"><%= @layer.z_index %></td>
        <td width="20" align="right"><input value={style_or_default(@layer, :background_color)} id={"#{@layer.id}-layer_background"} phx-hook="RenewStyleAttribute" rnw-layer-id={"#{@layer.id}"} rnw-element="layer" rnw-style="background_color" style="padding: 0; width: 2em; height: 2em" type="color" /></td>
        <td style={"cursor: pointer; padding-left: #{2*@depth}em"} phx-click="select_layer" phx-value-id={@layer.id}><%= @layer.id %><br><small><code><%= @layer.semantic_tag %></code></small></td>
      </tr>
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
end
