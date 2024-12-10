defmodule RenewCollabWeb.RenewComponents do
  use Phoenix.Component

  attr :document, :map, required: true
  attr :filter, :atom, default: nil
  slot :item, required: true

  def layers(assigns) do
    ~H"""
    <%= for layer <- @document.layers, layer.direct_parent_hood == nil and of_type(@filter, layer) do %>
      {render_slot(@item, layer)}
      <.child_layers document={@document} parent_id={layer.id} filter={@filter}>
        <:item :let={child_layer}>
          {render_slot(@item, child_layer)}
        </:item>
      </.child_layers>
    <% end %>
    """
  end

  attr :document, :map, required: true
  attr :parent_id, :string, required: true
  attr :filter, :atom, default: nil
  slot :item, required: true

  defp child_layers(assigns) do
    ~H"""
    <%= for layer <- @document.layers, layer.direct_parent_hood, layer.direct_parent_hood.ancestor_id == @parent_id and of_type(@filter, layer) do %>
      {render_slot(@item, layer)}
      <.child_layers document={@document} parent_id={layer.id} filter={@filter}>
        <:item :let={child_layer}>
          {render_slot(@item, child_layer)}
        </:item>
      </.child_layers>
    <% end %>
    """
  end

  defp of_type(nil, _), do: true
  defp of_type(:box, layer), do: not is_nil(layer.box) or is_group(layer)
  defp of_type(:text, layer), do: not is_nil(layer.text) or is_group(layer)
  defp of_type(:edge, layer), do: not is_nil(layer.edge) or is_group(layer)

  defp is_group(layer), do: is_nil(layer.box) and is_nil(layer.text) and is_nil(layer.edge)
end
