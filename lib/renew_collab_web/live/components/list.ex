defmodule RenewCollabWeb.HierarchyListComponent do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <table border="1" style="border-collapse: collapse;width:100%" cellspacing="0">
        <thead>
          <tr>
            <td width="20" align="center" style="padding: 5px">Vis</td>

            <td width="20" align="center" style="padding: 5px">Link</td>

            <td width="20" align="center" style="padding: 5px">Box</td>

            <td width="20" align="center" style="padding: 5px">Text</td>

            <td width="20" align="center" style="padding: 5px">Edge</td>

            <td width="20" align="right" style="padding: 5px">Ord.</td>

            <td width="20" align="right" style="padding: 5px"></td>

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
    assigns = assign(assigns, :depth, depth)

    ~H"""
    <%= for layer <- @document.layers, layer.direct_parent == nil do %>
      <.live_component
        document={@document}
        socket_schemas={@socket_schemas}
        symbols={@symbols}
        id={layer.id}
        module={RenewCollabWeb.HierarchyRowComponent}
        layer={layer}
        selected={@selection == layer.id}
        depth={@depth}
      /> <%= layer_hierarchy(assigns, @depth + 1, layer.id) %>
    <% end %>
    """
  end

  defp layer_hierarchy(assigns, depth, parent_id) do
    assigns = assign(assigns, :depth, depth)

    ~H"""
    <%= for layer <- @document.layers, layer.direct_parent, layer.direct_parent.ancestor_id == parent_id do %>
      <.live_component
        document={@document}
        socket_schemas={@socket_schemas}
        symbols={@symbols}
        id={layer.id}
        module={RenewCollabWeb.HierarchyRowComponent}
        layer={layer}
        selected={@selection == layer.id}
        depth={@depth}
      /> <%= layer_hierarchy(assigns, @depth + 1, layer.id) %>
    <% end %>
    """
  end
end
