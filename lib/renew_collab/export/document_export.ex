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
        # |> dbg()
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

      Hierarchy.is_subtype_of(
        grammar,
        layer.semantic_tag,
        "CH.ifa.draw.figures.GroupFigure"
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

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.TransitionFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              attributes: export_attributes(:box, layer),
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
              attributes: export_attributes(:box, layer),
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
              attributes: export_attributes(:box, layer),
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
              attributes: export_attributes(:box, layer),
              x: round(layer.box.position_x),
              y: round(layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              rotation: export_triangle_rotation(layer.box.symbol_shape)
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.RectangleFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              attributes: export_attributes(:box, layer),
              x: round(layer.box.position_x),
              y: round(layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height)
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.PolyLineFigure") ->
        [
          %Storable{
            class_name: layer.semantic_tag,
            fields: %{
              attributes: export_attributes(:edge, layer),
              points:
                Enum.concat([
                  [%{x: round(layer.edge.source_x), y: round(layer.edge.source_y)}],
                  layer.edge.waypoints
                  |> Enum.map(fn w -> %{x: round(w.position_x), y: round(w.position_y)} end),
                  [%{x: round(layer.edge.target_x), y: round(layer.edge.target_y)}]
                ]),
              start_decoration: nil,
              end_decoration: nil,
              arrow_name: "",
              start: nil,
              end: nil
            }
          }
        ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.fs.FSFigure") ->
        if is_nil(layer.text.style) do
          [
            %Storable{
              class_name: layer.semantic_tag,
              fields: %{
                attributes: export_attributes(:text, layer),
                fOriginX: round(layer.text.position_x),
                fOriginY: round(layer.text.position_y),
                text: layer.text.body,
                fCurrentFontName: "SansSerif",
                fCurrentFontStyle: 0,
                fCurrentFontSize: 12,
                fIsReadOnly: 0,
                fParent: nil,
                fLocator: nil,
                fType: 0,
                paths: [""]
              }
            }
          ]
        else
          [
            %Storable{
              class_name: layer.semantic_tag,
              fields: %{
                attributes: export_attributes(:text, layer),
                fOriginX: round(layer.text.position_x),
                fOriginY: round(layer.text.position_y),
                text: layer.text.body,
                fCurrentFontName: style_or_default(layer.text, :font_family),
                fCurrentFontStyle: export_font_style(layer.text.style),
                fCurrentFontSize: round(style_or_default(layer.text, :font_size)),
                fIsReadOnly: 0,
                fParent: nil,
                fLocator: nil,
                fType: 0,
                paths: [""]
              }
            }
          ]
        end

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.TextFigure") ->
        if is_nil(layer.text.style) do
          [
            %Storable{
              class_name: layer.semantic_tag,
              fields: %{
                attributes: export_attributes(:text, layer),
                fOriginX: round(layer.text.position_x),
                fOriginY: round(layer.text.position_y),
                text: layer.text.body,
                fCurrentFontName: "SansSerif",
                fCurrentFontStyle: 0,
                fCurrentFontSize: 12,
                fIsReadOnly: 0,
                fParent: nil,
                fLocator: nil,
                fType: 0
              }
            }
          ]
        else
          [
            %Storable{
              class_name: layer.semantic_tag,
              fields: %{
                attributes: export_attributes(:text, layer),
                fOriginX: round(layer.text.position_x),
                fOriginY: round(layer.text.position_y),
                text: layer.text.body,
                fCurrentFontName: style_or_default(layer.text, :font_family),
                fCurrentFontStyle: export_font_style(layer.text.style),
                fCurrentFontSize: round(style_or_default(layer.text, :font_size)),
                fIsReadOnly: 0,
                fParent: nil,
                fLocator: nil,
                fType: 0
              }
            }
          ]
        end

      true ->
        []
    end
  end

  defp export_attributes(:box, layer) do
    %Storable{
      class_name: "CH.ifa.draw.figures.FigureAttributes",
      fields: %{
        attributes: [
          {"FillColor", "Color",
           color_to_rgba(
             style_or_default(layer, :background_color),
             style_or_default(layer, :opacity)
           )},
          {"FrameColor", "Color",
           color_to_rgba(
             style_or_default(layer, :border_color),
             style_or_default(layer, :opacity)
           )},
          {"LineWidth", "Int",
           round(Integer.parse(style_or_default(layer, :border_width)) |> elem(0))}
        ]
      }
    }
  end

  defp export_attributes(:edge, _layer) do
    %Storable{
      class_name: "CH.ifa.draw.figures.FigureAttributes",
      fields: %{
        attributes: [{"Test", "Color", {:rgba, 100, 100, 200, 50}}]
      }
    }
  end

  defp export_attributes(:text, layer) do
    with layer_style <- layer.style,
         text_style <- layer.text.style,
         true <- not is_nil(layer_style),
         true <- not is_nil(text_style) do
      %Storable{
        class_name: "CH.ifa.draw.figures.FigureAttributes",
        fields: %{
          attributes: [
            {"TextAlignment", "Int",
             case style_or_default(layer.text, :alignment) do
               :left -> 0
               :center -> 1
               :right -> 2
             end},
            {"TextColor", "Color",
             color_to_rgba(
               style_or_default(layer.text, :text_color),
               style_or_default(layer, :opacity)
             )},
            {"FillColor", "Color",
             color_to_rgba(
               style_or_default(layer, :background_color),
               style_or_default(layer, :opacity)
             )},
            {"FrameColor", "Color",
             color_to_rgba(
               style_or_default(layer, :border_color),
               style_or_default(layer, :opacity)
             )},
            {"LineWidth", "Int",
             round(Integer.parse(style_or_default(layer, :border_width)) |> elem(0))}
          ]
        }
      }
    else
      _ -> nil
    end
  end

  defp color_to_rgba("black", opacity) do
    {:rgba, 0, 0, 0, round(255 * opacity)}
  end

  defp color_to_rgba(<<"#", rr::bytes-size(2), gg::bytes-size(2), bb::bytes-size(2)>>, opacity) do
    {r, ""} = Integer.parse(rr, 16)
    {g, ""} = Integer.parse(gg, 16)
    {b, ""} = Integer.parse(bb, 16)
    {:rgba, r, g, b, round(255 * dbg(opacity))}
  end

  defp color_to_rgba(
         <<"#", rr::bytes-size(2), gg::bytes-size(2), bb::bytes-size(2), aa::bytes-size(2)>>,
         opacity
       ) do
    {r, ""} = Integer.parse(rr, 16)
    {g, ""} = Integer.parse(gg, 16)
    {b, ""} = Integer.parse(bb, 16)
    {a, ""} = Integer.parse(aa, 16)
    {:rgba, r, g, b, round(a * opacity)}
  end

  defp color_to_rgba(<<"#", rr::bytes-size(1), gg::bytes-size(1), bb::bytes-size(1)>>, opacity) do
    {r, ""} = Integer.parse(rr, 16)
    {g, ""} = Integer.parse(gg, 16)
    {b, ""} = Integer.parse(bb, 16)

    {:rgba, Bitwise.bsl(r, 8) + r, Bitwise.bsl(g, 8) + g, Bitwise.bsl(b, 8) + b,
     round(255 * opacity)}
  end

  defp color_to_rgba(
         <<"#", rr::bytes-size(1), gg::bytes-size(1), bb::bytes-size(1), aa::bytes-size(1)>>,
         opacity
       ) do
    {r, ""} = Integer.parse(rr, 16)
    {g, ""} = Integer.parse(gg, 16)
    {b, ""} = Integer.parse(bb, 16)
    {a, ""} = Integer.parse(aa, 16)

    {:rgba, Bitwise.bsl(r, 8) + r, Bitwise.bsl(g, 8) + g, Bitwise.bsl(b, 8) + b,
     round(Bitwise.bsl(a, 8) + a * opacity)}
  end

  defp color_to_rgba(
         <<"rgba", args::utf8>>,
         opacity
       ) do
    [r, g, b, a] =
      Regex.run(~r/\(([^,]+),([^,]+),([^,]+),([^\)]+)\)/, args, capture: :all_but_first)
      |> Enum.map(&Float.parse/1)
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(&round/1)

    {:rgba, r, g, b, round(250 * a * opacity)}
  end

  defp color_to_rgba(
         <<"rgb", args::binary>>,
         opacity
       ) do
    [r, g, b] =
      Regex.run(~r/\(([^,]+),([^,]+),([^\)]+)\)/, args, capture: :all_but_first)
      |> Enum.map(&Float.parse/1)
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(&round/1)

    {:rgba, r, g, b, round(250 * opacity)}
  end

  defp color_to_rgba("transparent", _opacity) do
    {:rgba, 255, 199, 158, 0}
  end

  defp color_to_rgba(_color, _opacity) do
    {:rgba, 255, 199, 158, 0}
  end

  defp export_font_style(text_style) do
    [
      if(text_style.underline, do: 4, else: 0),
      if(text_style.bold, do: 1, else: 0),
      if(text_style.italic, do: 2, else: 0)
    ]
    |> Enum.reduce(0, &Bitwise.bor/2)
  end

  defp export_triangle_rotation(symbol) do
    case symbol.name do
      "triangle-up" -> 0
      "triangle-ne" -> 1
      "triangle-right" -> 2
      "triangle-se" -> 3
      "triangle-down" -> 4
      "triangle-sw" -> 5
      "triangle-left" -> 6
      "triangle-nw" -> 7
    end
  end

  defp style_or_default(%{:style => nil}, style_key) do
    default_style(style_key)
  end

  defp style_or_default(%{:style => style}, style_key) do
    with %{^style_key => value} <- style do
      value || default_style(style_key)
    else
      _ -> default_style(style_key)
    end
  end

  defp default_style(:background_color), do: "#70DB93"
  defp default_style(:opacity), do: 1.0
  defp default_style(:border_width), do: "1"
  defp default_style(_style_key), do: nil
end
