defmodule RenewCollabWeb.HierarchyListComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
      <div>

      <table border="1" cellspacing="0" cellpadding="5">
        <thead>
          <tr>
            <td width="20" align="center">Vis</td>
            <td width="20" align="center">Box</td>
            <td width="20" align="center">Text</td>
            <td width="20" align="center">Edge</td>
            <td width="20" align="right">Ord.</td>
            <td width="20" align="right">Style.</td>
            <td>
              ID/Type
            </td>
          </tr>
        </thead>
        <tbody>

        <%= layer_hierarchy(assigns, 0, nil) %>
      </tbody>
      </table>
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
          <.live_component id={layer.id}  module={RenewCollabWeb.HierarchyRowComponent} layer={layer} selected={@selection == layer.id} depth={depth} />
          <%= layer_hierarchy(assigns, depth+1, layer.id) %>
        <% end %>
    """
  end
end
