defmodule RenewCollabWeb.BlueprintJSON do
  use RenewCollabWeb, :verified_routes

  @group_order ["Nodes", "Edges", "Shapes", "Text", "FA"]
  @item_order %{
    "Nodes" => ["Transition", "Virtual Transition", "Place", "Virtual Place"],
    "Edges" => [
      "Edge",
      "Connection",
      "Angle Connection",
      "Test Arc",
      "Reservation Arc",
      "Flexible Arc",
      "Inhibitor Arc",
      "Clear Arc"
    ],
    "Shapes" => [
      "Rectangle",
      "Round Rectangle",
      "Ellipse",
      "Pie Segment",
      "Diamond",
      "Triangle",
      "Line",
      "Target",
      "Image"
    ],
    "Text" => ["Free Text", "Connected Text", "Inscription", "Name", "Declaration", "Comment"],
    "FA" => ["State"]
  }
  @arrow_tip_normal "84DC6617-D555-4BAB-BA33-04A5FA442F00"
  @arrow_tip_double "1BB93575-6759-4C59-8ED3-626949D1326A"
  @arrow_tip_circle "2FD06A6E-6B3E-4AD4-8728-4BE95A8A1451"
  @edge_icon """
  <path d="M 5 27 L 27 5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="butt" />
  <path d="M 27 5 L 22.6 6.4 L 25.6 9.4 Z" fill="currentColor" stroke="currentColor" stroke-linejoin="miter" />
  """
  @double_edge_icon """
  <path d="M 5 27 L 27 5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="butt" />
  <path d="M 27 5 L 22.6 6.4 L 25.6 9.4 Z" fill="currentColor" stroke="currentColor" stroke-linejoin="miter" />
  <path d="M 5 27 L 9.4 25.6 L 6.4 22.6 Z" fill="currentColor" stroke="currentColor" stroke-linejoin="miter" />
  """
  @circle_edge_icon """
  <path d="M 5 27 L 27 5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="butt" />
  <circle cx="27" cy="5" r="3.2" fill="white" stroke="currentColor" stroke-width="2" />
  """
  @edge_tools [
    %{
      kind: "edge-tool",
      name: "Edge",
      data: %{
        semantic_tag: "de.renew.gui.ArcConnection",
        target_tip_symbol_shape_id: @arrow_tip_normal
      },
      icon: @edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Connection",
      data: %{
        semantic_tag: "CH.ifa.draw.figures.LineConnection",
        source_tip_symbol_shape_id: nil,
        target_tip_symbol_shape_id: nil
      },
      icon:
        ~s(<path d="M 5 27 L 27 5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="butt" />)
    },
    %{
      kind: "edge-tool",
      name: "Angle Connection",
      data: %{
        semantic_tag: "CH.ifa.draw.figures.ElbowConnection",
        source_tip_symbol_shape_id: nil,
        target_tip_symbol_shape_id: nil
      },
      icon:
        ~s(<path d="M 5 27 L 5 12 L 27 12" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="butt" />)
    },
    %{
      kind: "edge-tool",
      name: "Test Arc",
      data: %{
        semantic_tag: "de.renew.gui.ArcConnection",
        source_tip_symbol_shape_id: nil,
        target_tip_symbol_shape_id: nil
      },
      icon:
        ~s(<path d="M 5 27 L 27 5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="butt" />)
    },
    %{
      kind: "edge-tool",
      name: "Reservation Arc",
      data: %{
        semantic_tag: "de.renew.gui.ArcConnection",
        source_tip_symbol_shape_id: @arrow_tip_normal,
        target_tip_symbol_shape_id: @arrow_tip_normal
      },
      icon: @double_edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Flexible Arc",
      data: %{
        semantic_tag: "de.renew.gui.DoubleArcConnection",
        target_tip_symbol_shape_id: @arrow_tip_double
      },
      icon: @edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Inhibitor Arc",
      data: %{
        semantic_tag: "de.renew.gui.InhibitorConnection",
        source_tip_symbol_shape_id: @arrow_tip_circle,
        target_tip_symbol_shape_id: @arrow_tip_circle
      },
      icon: @circle_edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Clear Arc",
      data: %{
        semantic_tag: "de.renew.gui.HollowDoubleArcConnection",
        target_tip_symbol_shape_id: @arrow_tip_double
      },
      icon: @edge_icon
    }
  ]

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
        |> ensure_edge_tool_group()
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

  defp maybe_add_edge_tool("Edges", items), do: items ++ @edge_tools
  defp maybe_add_edge_tool(_name, items), do: items

  defp ensure_edge_tool_group(groups) do
    if Enum.any?(groups, &(&1.name == "Edges")) do
      groups
    else
      [%{name: "Edges", items: @edge_tools} | groups]
    end
  end

  defp item_order(group_name), do: Map.get(@item_order, group_name, [])

  defp ordered_index(order, value) do
    case Enum.find_index(order, &(&1 == value)) do
      nil -> length(order)
      index -> index
    end
  end
end
