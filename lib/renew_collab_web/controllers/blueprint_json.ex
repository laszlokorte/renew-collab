defmodule RenewCollabWeb.BlueprintJSON do
  use RenewCollabWeb, :verified_routes

  @group_order ["Nodes", "Text", "FA"]
  @item_order %{
    "Nodes" => ["Transition", "Place", "Edge"],
    "Text" => ["Free Text", "Inscription"],
    "FA" => ["State"]
  }
  @edge_tool %{
    kind: "edge-tool",
    name: "Edge",
    data: %{},
    icon: """
    <path d="M 5 27 L 27 5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="butt" />
    <path d="M 27 5 L 22.6 6.4 L 25.6 9.4 Z" fill="currentColor" stroke="currentColor" stroke-linejoin="miter" />
    """
  }

  def index(%{documents: documents}) do
    %{
      blueprints:
        documents
        |> Enum.map(fn doc ->
          %{name: doc.name, id: doc.id}
        end)
    }
  end

  def primitives(%{groups: groups}) do
    %{
      groups:
        groups
        |> Enum.map(&group_with_tool_items/1)
        |> Enum.filter(&(Enum.count(&1.items) > 0))
        |> Enum.sort_by(&ordered_index(@group_order, &1.name))
        |> Enum.map(fn group ->
          %{
            name: group.name,
            items: Enum.sort_by(group.items, &ordered_index(item_order(group.name), &1.name))
          }
        end)
    }
  end

  defp group_with_tool_items(group) do
    items =
      group.primitives
      |> Enum.map(fn primitive ->
        %{
          kind: "primitive",
          name: primitive.name,
          data: primitive.data,
          icon: primitive.icon
        }
      end)

    %{
      name: group.name,
      items: maybe_add_edge_tool(group.name, items)
    }
  end

  defp maybe_add_edge_tool("Nodes", items), do: items ++ [@edge_tool]
  defp maybe_add_edge_tool(_name, items), do: items

  defp item_order(group_name), do: Map.get(@item_order, group_name, [])

  defp ordered_index(order, value) do
    case Enum.find_index(order, &(&1 == value)) do
      nil -> length(order)
      index -> index
    end
  end
end
