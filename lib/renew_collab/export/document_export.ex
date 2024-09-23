defmodule RenewCollab.Export.DocumentExport do
  alias Renewex.Storable
  alias Renewex.Grammar
  alias Renewex.Hierarchy
  alias RenewCollab.Document.Document

  def export(%Document{} = document) do
    grammar = Grammar.new(11)

    Renewex.serialize_document(%Renewex.Document{
      version: 11,
      root: {:ref, 0},
      refs: [
        %Renewex.Storable{
          class_name: document.kind,
          fields: %{
            figures:
              for l <- document.layers,
                  is_nil(l.direct_parent),
                  exported_figures = export_figure(grammar, l, document),
                  fig <- exported_figures do
                fig
              end,
            icon: nil
          }
        }
        |> dbg()
      ],
      size: nil
    })
  end

  defp export_figure(grammar, layer, document) do
    cond do
      Hierarchy.is_subtype_of(
        grammar,
        layer.semantic_tag,
        "de.renew.netcomponents.NetComponentFigure"
      ) ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              figures:
                for l <- document.layers,
                    not is_nil(l.direct_parent),
                    l.direct_parent.ancestor_id == layer.id,
                    exported_figures = export_figure(grammar, l, document),
                    fig <- exported_figures do
                  fig
                end
            }
          }
        ]
        |> Enum.concat(
          for l <- document.layers,
              not is_nil(l.direct_parent),
              l.direct_parent.ancestor_id == layer.id,
              exported_figures = export_figure(grammar, l, document),
              fig <- exported_figures do
            fig
          end
        )

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.TransitionFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              x: round(layer.box.position_x),
              y: round(layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              highlight_figure: nil
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.VirtualPlaceFigure") ->
        [
          # %Storable{
          #   class_name: layer.semantic_tag,
          #   fields: %{
          #     x: 10,
          #     y: 10,
          #     w: 10,
          #     h: 10,
          #     highlight_figure: nil,
          #     place: nil
          #   }
          # }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.PlaceFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              x: round(layer.box.position_x),
              y: round(layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              highlight_figure: nil
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.EllipseFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              x: round(layer.box.position_x),
              y: round(layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height)
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.contrib.TriangleFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              x: round(layer.box.position_x),
              y: round(layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              rotation: 0
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.RectangleFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              x: round(layer.box.position_x),
              y: round(layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height)
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.LineConnection") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              start: nil,
              end: nil,
              points:
                Enum.concat([
                  [%{x: round(layer.edge.source_x), y: round(layer.edge.source_y)}],
                  layer.edge.waypoints
                  |> Enum.map(fn w -> %{x: round(w.position_x), y: round(w.position_y)} end),
                  [%{x: round(layer.edge.target_x), y: round(layer.edge.target_y)}]
                ]),
              start_decoration: nil,
              end_decoration: nil,
              arrow_name: ""
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.PolyLineFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              points:
                Enum.concat([
                  [%{x: round(layer.edge.source_x), y: round(layer.edge.source_y)}],
                  layer.edge.waypoints
                  |> Enum.map(fn w -> %{x: round(w.position_x), y: round(w.position_y)} end),
                  [%{x: round(layer.edge.target_x), y: round(layer.edge.target_y)}]
                ]),
              start_decoration: nil,
              end_decoration: nil,
              arrow_name: ""
            }
          }
        ]

      true ->
        []
    end
  end
end
