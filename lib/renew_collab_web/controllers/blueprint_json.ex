defmodule RenewCollabWeb.BlueprintJSON do
  use RenewCollabWeb, :verified_routes

  @group_order ["Nodes", "Edges", "Shapes", "Text", "FA"]
  @item_order %{
    "Nodes" => ["Transition Tool", "Virtual Transition Tool", "Place Tool", "Virtual Place Tool"],
    "Edges" => [
      "Arc Tool",
      "Connection Tool",
      "Elbow Connection Tool",
      "Test Arc Tool",
      "Reserve Arc Tool",
      "Flexible Arc Tool",
      "Inhibitor Arc Tool",
      "Clear Arc Tool"
    ],
    "Shapes" => [
      "Rectangle Tool",
      "Round Rectangle Tool",
      "Ellipse Tool",
      "Elliptical Arc/Pie Tool",
      "Diamond Tool",
      "Triangle Tool",
      "Line Tool",
      "Target Tool",
      "Image Tool"
    ],
    "Text" => [
      "Text Tool",
      "Connected Text Tool",
      "Inscription Tool",
      "Name Tool",
      "Declaration Tool",
      "Comment Tool"
    ],
    "FA" => [
      "FA Start State Tool",
      "FA State Tool",
      "FA End State Tool",
      "FA Start End State Tool",
      "FA Name Tool",
      "FA Inscription Tool",
      "FA Word Placement Tool",
      "FA ArcConnection Tool",
      "FA Loop ArcConnection Tool"
    ]
  }
  @arrow_tip_normal "84DC6617-D555-4BAB-BA33-04A5FA442F00"
  @arrow_tip_double "1BB93575-6759-4C59-8ED3-626949D1326A"
  @arrow_tip_circle "2FD06A6E-6B3E-4AD4-8728-4BE95A8A1451"
  @edge_icon """
  <path d="M 5 25 L 25 5" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="butt" />
  <path d="M 25 5 L 20.5 7.2 L 22.8 9.5 Z" fill="currentColor" stroke="currentColor" stroke-width="0.6" stroke-linejoin="miter" />
  """
  @double_edge_icon """
  <path d="M 5 25 L 25 5" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="butt" />
  <path d="M 25 5 L 20.5 7.2 L 22.8 9.5 Z" fill="currentColor" stroke="currentColor" stroke-width="0.6" stroke-linejoin="miter" />
  <path d="M 5 25 L 9.5 22.8 L 7.2 20.5 Z" fill="currentColor" stroke="currentColor" stroke-width="0.6" stroke-linejoin="miter" />
  """
  @double_tip_edge_icon """
  <path d="M 5 25 L 25 5" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="butt" />
  <path d="M 25 5 L 20.5 7.2 L 22.8 9.5 Z" fill="currentColor" stroke="currentColor" stroke-width="0.6" stroke-linejoin="miter" />
  <path d="M 21 9 L 16.5 11.2 L 18.8 13.5 Z" fill="currentColor" stroke="currentColor" stroke-width="0.6" stroke-linejoin="miter" />
  """
  @circle_edge_icon """
  <path d="M 6 24 L 21 9" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="butt" />
  <circle cx="24" cy="6" r="3.7" fill="white" stroke="currentColor" stroke-width="1.5" />
  """
  @plain_edge_icon """
  <path d="M 5 25 L 25 5" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="butt" />
  """
  @loop_edge_icon """
  <path d="M 9 20 C 3 12 7 5 15 5 C 23 5 27 12 22 19" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="butt" />
  <path d="M 22 19 L 18 16.5 L 18.8 21 Z" fill="currentColor" stroke="currentColor" stroke-width="0.6" stroke-linejoin="miter" />
  """
  @angle_edge_icon """
  <path d="M 7 8 L 7 23 L 23 23" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="butt" stroke-linejoin="miter" />
  """
  @edge_tools [
    %{
      kind: "edge-tool",
      name: "Arc Tool",
      data: %{
        semantic_tag: "de.renew.gui.ArcConnection",
        target_tip_symbol_shape_id: @arrow_tip_normal
      },
      icon: @edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Connection Tool",
      data: %{
        semantic_tag: "CH.ifa.draw.figures.LineConnection",
        source_tip_symbol_shape_id: nil,
        target_tip_symbol_shape_id: nil
      },
      icon: @plain_edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Elbow Connection Tool",
      data: %{
        semantic_tag: "CH.ifa.draw.figures.ElbowConnection",
        source_tip_symbol_shape_id: nil,
        target_tip_symbol_shape_id: nil
      },
      icon: @angle_edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Test Arc Tool",
      data: %{
        semantic_tag: "de.renew.gui.ArcConnection",
        source_tip_symbol_shape_id: nil,
        target_tip_symbol_shape_id: nil
      },
      icon: @plain_edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Reserve Arc Tool",
      data: %{
        semantic_tag: "de.renew.gui.ArcConnection",
        source_tip_symbol_shape_id: @arrow_tip_normal,
        target_tip_symbol_shape_id: @arrow_tip_normal
      },
      icon: @double_edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Flexible Arc Tool",
      data: %{
        semantic_tag: "de.renew.gui.DoubleArcConnection",
        target_tip_symbol_shape_id: @arrow_tip_double
      },
      icon: @double_tip_edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Inhibitor Arc Tool",
      data: %{
        semantic_tag: "de.renew.gui.InhibitorConnection",
        source_tip_symbol_shape_id: @arrow_tip_circle,
        target_tip_symbol_shape_id: @arrow_tip_circle
      },
      icon: @circle_edge_icon
    },
    %{
      kind: "edge-tool",
      name: "Clear Arc Tool",
      data: %{
        semantic_tag: "de.renew.gui.HollowDoubleArcConnection",
        target_tip_symbol_shape_id: @arrow_tip_double
      },
      icon: @double_tip_edge_icon
    }
  ]
  @fa_edge_tools [
    %{
      kind: "edge-tool",
      name: "FA ArcConnection Tool",
      data: %{
        semantic_tag: "de.renew.fa.figures.FAArcConnection",
        target_tip_symbol_shape_id: @arrow_tip_normal,
        smoothness: "bspline"
      },
      icon: @edge_icon
    },
    %{
      kind: "edge-tool",
      name: "FA Loop ArcConnection Tool",
      data: %{
        semantic_tag: "de.renew.fa.figures.FAArcConnection",
        target_tip_symbol_shape_id: @arrow_tip_normal,
        smoothness: "bspline",
        loop: true
      },
      icon: @loop_edge_icon
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
  defp maybe_add_edge_tool("FA", items), do: items ++ @fa_edge_tools
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
