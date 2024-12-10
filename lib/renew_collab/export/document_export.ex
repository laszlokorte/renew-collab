defmodule RenewCollab.Export.DocumentExport do
  alias RenewCollab.ViewBox
  alias Renewex.Storable
  alias Renewex.Grammar
  alias Renewex.Hierarchy
  alias RenewCollab.Document.Document

  def export(%Document{} = document) do
    grammar = Grammar.new(11)

    view_box = ViewBox.calculate(document, 20)

    document =
      Map.update(document, :layers, nil, fn layers ->
        Enum.sort_by(
          layers,
          &{not (is_nil(&1.box) and is_nil(&1.edge) and is_nil(&1.text)), is_nil(&1.box),
           is_nil(&1.edge), is_nil(&1.text)}
        )
      end)

    refs =
      document.layers
      |> Enum.filter(fn l ->
        is_nil(l.direct_parent_hood)
      end)
      |> Enum.reduce([], fn layer, storables ->
        export_layer(storables, view_box, document, grammar, layer)
      end)
      |> attach_syntetic_labels

    Renewex.serialize_document(%Renewex.Document{
      version: 11,
      root: %Renewex.Storable{
        class_name: document.kind,
        fields: %{
          figures:
            for {%{fields: %{_root: true}}, i} <- Enum.with_index(refs) do
              {:ref, i}
            end,
          icon: nil
        }
      },
      refs: refs,
      size: nil
    })
  end

  def export_layer(prev_storables, view_box, document, grammar, layer) do
    child_storables =
      document.layers
      |> Enum.filter(fn l ->
        not is_nil(l.direct_parent_hood) and l.direct_parent_hood.ancestor_id == layer.id
      end)

    storables =
      child_storables
      |> Enum.reduce(prev_storables, fn sub_layer, acc_storables ->
        export_layer(acc_storables, view_box, document, grammar, sub_layer)
      end)

    cond do
      # Hierarchy.is_subtype_of(
      #   grammar,
      #   layer.semantic_tag,
      #   "de.renew.netcomponents.NetComponentFigure"
      # ) ->
      #   [
      #     %Renewex.Storable{
      #       class_name: layer.semantic_tag,
      #       fields: %{
      #         figures:
      #           for {l, li} <- Enum.with_index(document.layers),
      #               not is_nil(l.direct_parent_hood),
      #               l.direct_parent_hood.ancestor_id == layer.id,
      #               exported_figures = export_child_figure(grammar, l, li, document),
      #               fig <- exported_figures do
      #             fig
      #           end
      #       }
      #     }
      #   ]
      #   |> Enum.concat(
      #     for {l, li} <- Enum.with_index(document.layers),
      #         not is_nil(l.direct_parent_hood),
      #         l.direct_parent_hood.ancestor_id == layer.id,
      #         exported_figures = export_child_figure(grammar, l, li, document),
      #         fig <- exported_figures do
      #       fig
      #     end
      #   )

      # Hierarchy.is_subtype_of(
      #   grammar,
      #   layer.semantic_tag,
      #   "CH.ifa.draw.figures.GroupFigure"
      # ) ->
      #   [
      #     %Renewex.Storable{
      #       class_name: layer.semantic_tag,
      #       fields: %{
      #         figures:
      #           for {l, li} <- Enum.with_index(document.layers),
      #               not is_nil(l.direct_parent_hood),
      #               l.direct_parent_hood.ancestor_id == layer.id,
      #               exported_figures = export_child_figure(grammar, l, li, document),
      #               fig <- exported_figures do
      #             fig
      #           end
      #       }
      #     }
      #   ]

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.TransitionFigure") ->
        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              # layer.direct_parent_hood == nil,
              _root: true,
              _gen_id: layer.id,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              highlight_figure: nil
            }
          }
        ])

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.VirtualPlaceFigure") ->
        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              # layer.direct_parent_hood == nil,
              _root: true,
              _gen_id: layer.id,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              highlight_figure: nil,
              place:
                with out when not is_nil(out) <- layer.outgoing_link,
                     target_layer_id when not is_nil(target_layer_id) <- out.target_layer_id do
                  Enum.find_value(Enum.with_index(storables), fn
                    {%{fields: %{_gen_id: ^target_layer_id}}, i} -> {:ref, i}
                    _ -> nil
                  end)
                end
            }
          }
        ])

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.PlaceFigure") ->
        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              # layer.direct_parent_hood == nil,
              _root: true,
              _gen_id: layer.id,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              highlight_figure: nil
            }
          }
        ])

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.EllipseFigure") ->
        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              # layer.direct_parent_hood == nil,
              _root: true,
              _gen_id: layer.id,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height)
            }
          }
        ])

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.contrib.TriangleFigure") ->
        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              # layer.direct_parent_hood == nil,
              _root: true,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              rotation: export_triangle_rotation(layer.box.symbol_shape)
            }
          }
        ])

      Hierarchy.is_subtype_of(
        grammar,
        layer.semantic_tag,
        "CH.ifa.draw.figures.RectangleFigure"
      ) ->
        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              # layer.direct_parent_hood == nil,
              _root: true,
              _gen_id: layer.id,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height)
            }
          }
        ])

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.PolyLineFigure") ->
        {storables, source_arrow_ref} =
          create_ref(
            storables,
            case layer.edge.style.source_tip_symbol_shape_id do
              nil ->
                nil

              _ ->
                %Renewex.Storable{
                  class_name: "CH.ifa.draw.figures.ArrowTip",
                  fields: %{
                    angle: 0.4,
                    outer_radius: 8.0,
                    inner_radius: 8.0,
                    filled: true
                  }
                }
            end
          )

        {storables, target_arrow_ref} =
          create_ref(
            storables,
            case layer.edge.style.target_tip_symbol_shape_id do
              nil ->
                nil

              _ ->
                %Renewex.Storable{
                  class_name: "CH.ifa.draw.figures.ArrowTip",
                  fields: %{
                    angle: 0.4,
                    outer_radius: 8.0,
                    inner_radius: 8.0,
                    filled: true
                  }
                }
            end
          )

        {storables, start_ref} =
          create_ref(
            storables,
            case layer.edge.source_bond do
              %{layer_id: layer_id} ->
                {:ref,
                 target_index =
                   Enum.find_index(storables, fn
                     %{fields: %{_gen_id: ^layer_id}} -> true
                     _ -> false
                   end)}

                %Renewex.Storable{
                  class_name: "CH.ifa.draw.standard.ChopBoxConnector",
                  fields: %{
                    owner: {:ref, target_index}
                  }
                }
            end
          )

        {storables, end_ref} =
          create_ref(
            storables,
            case layer.edge.target_bond do
              %{layer_id: layer_id} ->
                {:ref,
                 target_index =
                   Enum.find_index(storables, fn
                     %{fields: %{_gen_id: ^layer_id}} -> true
                     _ -> false
                   end)}

                %Renewex.Storable{
                  class_name: "CH.ifa.draw.standard.ChopBoxConnector",
                  fields: %{
                    owner: {:ref, target_index}
                  }
                }
            end
          )

        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              _gen_id: layer.id,
              # layer.direct_parent_hood == nil,
              _root: true,
              attributes: export_attributes(:edge, layer),
              points:
                Enum.concat([
                  [
                    %{
                      x: round(-view_box.x + layer.edge.source_x),
                      y: round(-view_box.y + layer.edge.source_y)
                    }
                  ],
                  layer.edge.waypoints
                  |> Enum.map(fn w ->
                    %{x: round(w.position_x - view_box.x), y: round(w.position_y - view_box.y)}
                  end),
                  [
                    %{
                      x: round(-view_box.x + layer.edge.target_x),
                      y: round(-view_box.y + layer.edge.target_y)
                    }
                  ]
                ]),
              start_decoration: source_arrow_ref,
              end_decoration: target_arrow_ref,
              arrow_name: "",
              start: start_ref,
              end: end_ref
            }
          }
        ])

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.fs.FSFigure") ->
        if is_nil(layer.text.style) do
          storables
          |> Enum.concat([
            %Renewex.Storable{
              class_name: layer.semantic_tag,
              fields: %{
                # layer.direct_parent_hood == nil,
                _root: true,
                attributes: export_attributes(:text, layer),
                fOriginX: round(-view_box.x + layer.text.position_x),
                fOriginY: round(-view_box.y + layer.text.position_y),
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
          ])
        else
          storables
          |> Enum.concat([
            %Renewex.Storable{
              class_name: layer.semantic_tag,
              fields: %{
                # layer.direct_parent_hood == nil,
                _root: true,
                attributes: export_attributes(:text, layer),
                fOriginX: round(-view_box.x + layer.text.position_x),
                fOriginY: round(-view_box.y + layer.text.position_y),
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
          ])
        end

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "de.renew.gui.CPNTextFigure") ->
        if is_nil(layer.text.style) do
          parent_ref =
            with out when not is_nil(out) <- layer.outgoing_link,
                 target_layer_id when not is_nil(target_layer_id) <- out.target_layer_id do
              Enum.find_value(Enum.with_index(storables), fn
                {%{fields: %{_gen_id: ^target_layer_id}}, i} -> {:ref, i}
                _ -> nil
              end)
            end

          {storables, locator_ref} =
            if parent_ref do
              {storables, locator_base} =
                create_ref(storables, %Renewex.Storable{
                  class_name: "CH.ifa.draw.standard.RelativeLocator",
                  fields: %{
                    fOffsetY: 0.5,
                    fOffsetX: 0.5
                  }
                })

              create_ref(storables, %Renewex.Storable{
                class_name: "CH.ifa.draw.standard.OffsetLocator",
                fields: %{
                  fOffsetY: 0,
                  fOffsetX: 0,
                  fBase: locator_base
                }
              })
            else
              {storables, nil}
            end

          storables
          |> Enum.concat([
            %Renewex.Storable{
              class_name: layer.semantic_tag,
              fields: %{
                # layer.direct_parent_hood == nil,
                _root: true,
                _gen_id: layer.id,
                attributes: export_attributes(:text, layer),
                fOriginX: round(-view_box.x + layer.text.position_x),
                fOriginY: round(-view_box.y + layer.text.position_y),
                text: layer.text.body,
                fCurrentFontName: "SansSerif",
                fCurrentFontStyle: 0,
                fCurrentFontSize: 12,
                fIsReadOnly: 0,
                fParent: parent_ref,
                fLocator: locator_ref,
                fType: if(locator_ref, do: 1, else: 0)

                # CH.ifa.draw.standard.OffsetLocator 0 0 
                #     CH.ifa.draw.standard.RelativeLocator 0.5 0.5   1  NULL 
              }
            }
          ])
        else
          parent_ref =
            with out when not is_nil(out) <- layer.outgoing_link,
                 target_layer_id when not is_nil(target_layer_id) <- out.target_layer_id do
              Enum.find_value(Enum.with_index(storables), fn
                {%{fields: %{_gen_id: ^target_layer_id}}, i} -> {:ref, i}
                _ -> nil
              end)
            end

          {storables, locator_ref} =
            if parent_ref do
              {storables, locator_base} =
                create_ref(storables, %Renewex.Storable{
                  class_name: "CH.ifa.draw.standard.RelativeLocator",
                  fields: %{
                    fOffsetY: 0.5,
                    fOffsetX: 0.5
                  }
                })

              create_ref(storables, %Renewex.Storable{
                class_name: "CH.ifa.draw.standard.OffsetLocator",
                fields: %{
                  fOffsetY: 0,
                  fOffsetX: 0,
                  fBase: locator_base
                }
              })
            else
              {storables, nil}
            end

          storables
          |> Enum.concat([
            %Renewex.Storable{
              class_name: layer.semantic_tag,
              fields: %{
                # layer.direct_parent_hood == nil,
                _root: true,
                attributes: export_attributes(:text, layer),
                fOriginX: round(-view_box.x + layer.text.position_x),
                fOriginY: round(-view_box.y + layer.text.position_y),
                text: layer.text.body,
                fCurrentFontName: style_or_default(layer.text, :font_family),
                fCurrentFontStyle: export_font_style(layer.text.style),
                fCurrentFontSize: round(style_or_default(layer.text, :font_size)),
                fIsReadOnly: 0,
                fParent: parent_ref,
                fLocator: locator_ref,
                fType: if(locator_ref, do: 1, else: 0)
              }
            }
          ])
        end

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.TextFigure") ->
        if is_nil(layer.text.style) do
          storables
          |> Enum.concat([
            %Renewex.Storable{
              class_name: layer.semantic_tag,
              fields: %{
                # layer.direct_parent_hood == nil,
                _root: true,
                attributes: export_attributes(:text, layer),
                fOriginX: round(-view_box.x + layer.text.position_x),
                fOriginY: round(-view_box.y + layer.text.position_y),
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
          ])
        else
          storables
          |> Enum.concat([
            %Renewex.Storable{
              class_name: layer.semantic_tag,
              fields: %{
                # layer.direct_parent_hood == nil,
                _root: true,
                attributes: export_attributes(:text, layer),
                fOriginX: round(-view_box.x + layer.text.position_x),
                fOriginY: round(-view_box.y + layer.text.position_y),
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
          ])
        end

      Hierarchy.is_subtype_of(
        grammar,
        layer.semantic_tag,
        "CH.ifa.draw.figures.GroupFigure"
      ) ||
          Hierarchy.is_subtype_of(
            grammar,
            layer.semantic_tag,
            "de.renew.netcomponents.NetComponentFigure"
          ) ->
        storables
        # |> Enum.concat(
        #   for c <- child_storables,
        #       cid = c.id,
        #       strbl =
        #         Enum.find_value(storables, fn
        #           %{fields: %{_gen_id: ^cid}} = s ->
        #             Map.update(s, :fields, %{}, &Map.put(&1, :_root, true))

        #           _ ->
        #             nil
        #         end),
        #       not is_nil(strbl) do
        #     strbl
        #   end
        # )
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              # layer.direct_parent_hood == nil,
              _root: true,
              _gen_id: layer.id,
              figures:
                for c <- child_storables,
                    cid = c.id,
                    ref =
                      Enum.find_value(Enum.with_index(storables), fn
                        {%{fields: %{_gen_id: ^cid}}, i} -> {:ref, i}
                        _ -> nil
                      end),
                    not is_nil(ref) do
                  ref
                end
            }
          }
        ])

      true ->
        []
    end
  end

  defp attach_syntetic_labels(refs) do
    refs
    |> Enum.concat(
      for {%Storable{class_name: class_name, fields: %{_gen_id: gen_id}}, index} <-
            Enum.with_index(refs),
          class_name == "de.renew.gui.TransitionFigure" or
            class_name == "de.renew.gui.PlaceFigure" do
        %Renewex.Storable{
          class_name: "de.renew.gui.CPNTextFigure",
          fields: %{
            _root: true,
            attributes: %Renewex.Storable{
              class_name: "CH.ifa.draw.figures.FigureAttributes",
              fields: %{
                attributes: [
                  {"Visible", "Boolean", true}
                ]
              }
            },
            fOriginX: 0,
            fOriginY: 0,
            text: gen_id,
            fCurrentFontName: "monospaced",
            fCurrentFontStyle: 0,
            fCurrentFontSize: 2,
            fIsReadOnly: 0,
            fParent: {:ref, index},
            fLocator: %Renewex.Storable{
              class_name: "CH.ifa.draw.standard.OffsetLocator",
              fields: %{
                fOffsetY: 0,
                fOffsetX: 0,
                fBase: %Renewex.Storable{
                  class_name: "CH.ifa.draw.standard.RelativeLocator",
                  fields: %{
                    fOffsetY: 0.5,
                    fOffsetX: 0.5
                  }
                }
              }
            },
            fType: 2
          }
        }
      end
    )
  end

  defp export_attributes(:box, layer) do
    %Renewex.Storable{
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
          {"LineWidth", "Int", round(style_or_default(layer, :border_width))}
        ]
      }
    }
  end

  defp export_attributes(:edge, _layer) do
    %Renewex.Storable{
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
      %Renewex.Storable{
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
            {"LineWidth", "Int", round(style_or_default(layer, :border_width))}
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
    {:rgba, r, g, b, round(255 * opacity)}
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

  @rgba_paren ~r/\(([^,]+),([^,]+),([^,]+),([^\)]+)\)/

  defp color_to_rgba(
         <<"rgba", args::binary>>,
         opacity
       ) do
    foo =
      Regex.run(@rgba_paren, args, capture: :all_but_first)

    [r, g, b, a] =
      foo
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
  defp default_style(:border_width), do: 1
  defp default_style(_style_key), do: nil

  defp create_ref(storables, nil), do: {storables, nil}

  defp create_ref(storables, s = %Storable{}),
    do: {Enum.concat(storables, [s]), {:ref, Enum.count(storables)}}
end
