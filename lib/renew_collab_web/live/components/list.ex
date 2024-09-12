defmodule RenewCollabWeb.HierarchyListComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <%= layer_hierarchy(assigns, 0, nil) %>
      </div>
    """
  end

  defp layer_hierarchy(assigns, depth, nil) do
    ~H"""
        <%= for layer <- @document.layers, layer.direct_parent == nil do %> 
          <.live_component id={layer.id} module={RenewCollabWeb.HierarchyRowComponent} layer={layer} selected={@selection == layer.id} depth={depth} />
          <%= layer_hierarchy(assigns, depth+1, layer.id) %>
        <% end %>
    """
  end

  defp layer_hierarchy(assigns, depth, parent_id) do
    ~H"""
        <%= for layer <- @document.layers, layer.direct_parent, layer.direct_parent.ancestor_id == parent_id do %> 
          <.live_component  id={layer.id}  module={RenewCollabWeb.HierarchyRowComponent} layer={layer} selected={@selection == layer.id} depth={depth} />
          <%= layer_hierarchy(assigns, depth+1, layer.id) %>
        <% end %>
    """
  end
end
