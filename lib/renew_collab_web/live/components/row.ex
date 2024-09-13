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
        <td style={"cursor: pointer; padding-left: #{2*@depth}em"} phx-click="select_layer" phx-value-id={@layer.id}>
          <%= @layer.id %><br><small><code><%= @layer.semantic_tag %></code></small>

          <%= if @selected do %>
          <div>
            <%= for {attr, type} <- [
            opacity: :number,
            background_color: :color,
            border_color: :color,
            border_width: :number,
            border_dash_array: :text,
            ] do %>
            <label>
              <%= attr %>
            <input value={style_or_default(@layer, attr)} id={"layer-style-#{@layer.id}-#{attr}"} phx-hook="RenewStyleAttribute" rnw-layer-id={"#{@layer.id}"} rnw-element="layer" rnw-style={attr} style="padding: 0; " type={type} />
            </label>
            <br>
            <% end %>
          </div>
          <%= unless is_nil(@layer.edge) do %>
          <div>
            <%= for {attr, type} <- [
            stroke_width: :number,
            stroke_color: :color,
            stroke_join: :text,
            stroke_cap: :text,
            stroke_dash_array: :text,
            smoothness: :number,
            source_tip_symbol_shape_id: :number,
            target_tip_symbol_shape_id: :number,
            ] do %>
            <label>
              <%= attr %>
            <input value={style_or_default(@layer.edge, attr)} id={"edge-style#{@layer.id}-#{attr}"} phx-hook="RenewStyleAttribute" rnw-layer-id={"#{@layer.id}"} rnw-element="edge" rnw-style={attr} style="padding: 0; " type={type} />
            </label><br>
            <% end %>
          </div>
          <% end %>
          <%= unless is_nil(@layer.text) do %>
          <div>
            <%= for {attr, type} <- [
            bold: :checkbox,
            italic: :checkbox,
            underline: :checkbox,
            alignment: :text,
            font_size: :number,
            font_family: :text,
            text_color: :color,
            ] do %>
            <label>
              <%= attr %>
            <input {if(type == :checkbox, do: [checked: style_or_default(@layer.text, attr)], else: [value: style_or_default(@layer.text, attr)])} id={"text-style-#{@layer.id}-#{attr}"} phx-hook="RenewStyleAttribute" rnw-layer-id={"#{@layer.id}"} rnw-element="text" rnw-style={attr} style="padding: 0; " type={type} />
            </label><br>
            <% end %>
          </div>
          <% end %>
          <% end %>
        </td>
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
