defmodule RenewCollab.Export.DocumentExport do
  alias RenewCollab.ViewBox
  alias Renewex.Storable
  alias Renewex.Grammar
  alias Renewex.Hierarchy
  alias Renewex.Serializer
  alias RenewCollab.Document.Document

  def export(%Document{} = document, opts \\ [synthetic: false]) do
    grammar = Grammar.new(11)
    sockets = RenewCollab.Sockets.all_socket_by_id()
    tip_ids = RenewCollab.Symbols.ids_by_name()

    view_box = ViewBox.calculate(document, 20)

    document =
      Map.update(document, :layers, nil, fn layers ->
        Enum.sort_by(
          layers,
          &{not (is_nil(&1.box) and is_nil(&1.edge) and is_nil(&1.text)), is_nil(&1.box),
           is_nil(&1.edge), is_nil(&1.text)}
        )
      end)

    layer_lookup = Map.new(document.layers, &{&1.id, &1})

    refs =
      document.layers
      |> Enum.filter(fn l ->
        is_nil(l.direct_parent_hood)
      end)
      |> Enum.reduce([], fn layer, storables ->
        export_layer(
          storables,
          view_box,
          document,
          grammar,
          sockets,
          tip_ids,
          layer,
          layer_lookup
        )
      end)

    refs =
      if Keyword.get(opts, :synthetic, false) do
        refs |> attach_synthetic_labels
      else
        refs
      end

    serialize_document(%Renewex.Document{
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

  defp serialize_document(%Renewex.Document{version: version, root: root, refs: refs, size: size}) do
    serializer = Serializer.new(refs, export_grammar(version))

    with {:ok, ser} <- Serializer.serialize_storable(serializer, root) do
      ser =
        if version == -1,
          do: ser,
          else: Serializer.prepend_token(ser, {:int, version})

      ser =
        if size == nil do
          ser
        else
          Enum.reduce(Tuple.to_list(size), ser, fn s, ser ->
            Serializer.append_token(ser, {:int, s})
          end)
        end

      {:ok, Serializer.get_output_string(ser)}
    end
  end

  defp export_grammar(version) do
    grammar = Grammar.new(version)
    fa_state_class = "de.renew.fa.figures.FAStateFigure"

    update_in(grammar.hierarchy[fa_state_class].fields, fn fields ->
      Enum.map(fields, fn
        {nil, [:ref, :string, default: {:string, "SKIPPED_WHILE_PARSING"}]} ->
          {nil, [:ref, :string, default: {:string, "de.renew.fa.figures.NullDecoration"}]}

        field ->
          field
      end)
    end)
  end

  def export_layer(prev_storables, view_box, document, grammar, sockets, layer) do
    export_layer(prev_storables, view_box, document, grammar, sockets, %{}, layer)
  end

  def export_layer(prev_storables, view_box, document, grammar, sockets, tip_ids, layer) do
    layer_lookup = Map.new(document.layers, &{&1.id, &1})

    export_layer(
      prev_storables,
      view_box,
      document,
      grammar,
      sockets,
      tip_ids,
      layer,
      layer_lookup
    )
  end

  def export_layer(
        prev_storables,
        view_box,
        document,
        grammar,
        sockets,
        tip_ids,
        layer,
        layer_lookup
      ) do
    child_storables =
      document.layers
      |> Enum.filter(fn l ->
        not is_nil(l.direct_parent_hood) and l.direct_parent_hood.ancestor_id == layer.id
      end)

    storables =
      child_storables
      |> Enum.reduce(prev_storables, fn sub_layer, acc_storables ->
        export_layer(
          acc_storables,
          view_box,
          document,
          grammar,
          sockets,
          tip_ids,
          sub_layer,
          layer_lookup
        )
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
        {storables, fa_state_fields} =
          create_fa_state_refs(storables, layer.semantic_tag)

        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields:
              %{
                # layer.direct_parent_hood == nil,
                _root: true,
                _gen_id: layer.id,
                attributes: export_attributes(:box, layer),
                x: round(-view_box.x + layer.box.position_x),
                y: round(-view_box.y + layer.box.position_y),
                w: round(layer.box.width),
                h: round(layer.box.height)
              }
              |> Map.merge(fa_state_fields)
          }
        ])

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.PieFigure") ->
        shape_attributes = layer.box.symbol_shape_attributes || %{}

        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              _root: true,
              _gen_id: layer.id,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              start_angle: Map.get(shape_attributes, "start_angle") || 0.0,
              end_angle: Map.get(shape_attributes, "end_angle") || 180.0
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
        "CH.ifa.draw.figures.RoundRectangleFigure"
      ) ->
        shape_attributes = layer.box.symbol_shape_attributes || %{}

        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              _root: true,
              _gen_id: layer.id,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              arc_width: round(Map.get(shape_attributes, "rx") || 0),
              arc_height: round(Map.get(shape_attributes, "ry") || 0)
            }
          }
        ])

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.ImageFigure") ->
        shape_attributes = layer.box.symbol_shape_attributes || %{}

        storables
        |> Enum.concat([
          %Renewex.Storable{
            class_name: layer.semantic_tag,
            fields: %{
              _root: true,
              _gen_id: layer.id,
              attributes: export_attributes(:box, layer),
              x: round(-view_box.x + layer.box.position_x),
              y: round(-view_box.y + layer.box.position_y),
              w: round(layer.box.width),
              h: round(layer.box.height),
              name:
                Map.get(shape_attributes, "image_name") ||
                  style(layer, :background_url) ||
                  ""
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

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.contrib.PolygonFigure") or
          Hierarchy.is_subtype_of(
            grammar,
            layer.semantic_tag,
            "CH.ifa.draw.figures.PolyLineFigure"
          ) ->
        {storables, source_arrow_ref} =
          create_ref(
            storables,
            export_edge_decoration(
              layer.edge.style && layer.edge.style.source_tip_symbol_shape_id,
              tip_ids,
              layer.semantic_tag
            )
          )

        {storables, target_arrow_ref} =
          create_ref(
            storables,
            export_edge_decoration(
              layer.edge.style && layer.edge.style.target_tip_symbol_shape_id,
              tip_ids,
              layer.semantic_tag
            )
          )

        {storables, start_ref} =
          case layer.edge.source_bond do
            %{layer_id: layer_id} ->
              target_index =
                Enum.find_index(storables, fn
                  %{fields: %{_gen_id: ^layer_id}} -> true
                  _ -> false
                end)

              create_ref(
                storables,
                %Renewex.Storable{
                  class_name: bond_to_connector(layer.edge.source_bond, sockets),
                  fields: %{
                    owner: {:ref, target_index}
                  }
                }
              )

            nil ->
              {storables, nil}
          end

        {storables, end_ref} =
          case layer.edge.target_bond do
            %{layer_id: layer_id} ->
              target_index =
                Enum.find_index(storables, fn
                  %{fields: %{_gen_id: ^layer_id}} -> true
                  _ -> false
                end)

              create_ref(
                storables,
                %Renewex.Storable{
                  class_name: bond_to_connector(layer.edge.target_bond, sockets),
                  fields: %{
                    owner: {:ref, target_index}
                  }
                }
              )

            nil ->
              {storables, nil}
          end

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
              arrow_name: "CH.ifa.draw.figures.ArrowTip",
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
                fIsReadOnly: false,
                fParent: nil,
                fLocator: nil,
                fType: export_text_type(layer, 0),
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
                fIsReadOnly: false,
                fParent: nil,
                fLocator: nil,
                fType: export_text_type(layer, 0),
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
                  fOffsetY: text_locator_offset(layer, layer_lookup, :y),
                  fOffsetX: text_locator_offset(layer, layer_lookup, :x),
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
                fIsReadOnly: false,
                fParent: parent_ref,
                fLocator: locator_ref,
                fType: export_text_type(layer, if(locator_ref, do: 1, else: 0))

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
                  fOffsetY: text_locator_offset(layer, layer_lookup, :y),
                  fOffsetX: text_locator_offset(layer, layer_lookup, :x),
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
                fIsReadOnly: false,
                fParent: parent_ref,
                fLocator: locator_ref,
                fType: export_text_type(layer, if(locator_ref, do: 1, else: 0))
              }
            }
          ])
        end

      Hierarchy.is_subtype_of(grammar, layer.semantic_tag, "CH.ifa.draw.figures.TextFigure") ->
        {storables, parent_ref, locator_ref} =
          create_text_locator(storables, layer, layer_lookup)

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
                fIsReadOnly: false,
                fParent: parent_ref,
                fLocator: locator_ref,
                fType: export_text_type(layer, 0)
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
                fIsReadOnly: false,
                fParent: parent_ref,
                fLocator: locator_ref,
                fType: export_text_type(layer, 0)
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

  defp create_fa_state_refs(storables, "de.renew.fa.figures.FAStateFigure") do
    {storables, decoration_ref} =
      create_ref(storables, %Storable{
        class_name: "de.renew.fa.figures.NullDecoration",
        fields: %{}
      })

    {storables,
     %{
       figure: nil,
       decoration: decoration_ref
     }}
  end

  defp create_fa_state_refs(storables, _semantic_tag), do: {storables, %{}}

  defp export_edge_decoration(nil, _tip_ids, _semantic_tag), do: nil

  defp export_edge_decoration(tip_id, tip_ids, semantic_tag) do
    cond do
      tip_id == Map.get(tip_ids, "arrow-tip-circle") ->
        %Renewex.Storable{class_name: "de.renew.gui.CircleDecoration", fields: %{}}

      tip_id == Map.get(tip_ids, "arrow-tip-double") ->
        %Renewex.Storable{
          class_name: "de.renew.gui.DoubleArrowTip",
          fields:
            export_arrow_tip_fields(semantic_tag != "de.renew.gui.HollowDoubleArcConnection")
        }

      true ->
        %Renewex.Storable{
          class_name: "CH.ifa.draw.figures.ArrowTip",
          fields: export_arrow_tip_fields(true)
        }
    end
  end

  defp export_arrow_tip_fields(filled) do
    %{
      angle: 0.4,
      outer_radius: 8.0,
      inner_radius: 8.0,
      filled: filled
    }
  end

  defp create_text_locator(storables, layer, layer_lookup) do
    parent_ref =
      with out when not is_nil(out) <- layer.outgoing_link,
           target_layer_id when not is_nil(target_layer_id) <- out.target_layer_id do
        Enum.find_value(Enum.with_index(storables), fn
          {%{fields: %{_gen_id: ^target_layer_id}}, i} -> {:ref, i}
          _ -> nil
        end)
      end

    if parent_ref do
      {storables, locator_base} =
        create_ref(storables, %Renewex.Storable{
          class_name: "CH.ifa.draw.standard.RelativeLocator",
          fields: %{
            fOffsetY: 0.5,
            fOffsetX: 0.5
          }
        })

      {storables, locator_ref} =
        create_ref(storables, %Renewex.Storable{
          class_name: "CH.ifa.draw.standard.OffsetLocator",
          fields: %{
            fOffsetY: text_locator_offset(layer, layer_lookup, :y),
            fOffsetX: text_locator_offset(layer, layer_lookup, :x),
            fBase: locator_base
          }
        })

      {storables, parent_ref, locator_ref}
    else
      {storables, nil, nil}
    end
  end

  defp export_text_type(%{text: %{renew_type: renew_type}}, _default)
       when is_integer(renew_type),
       do: renew_type

  defp export_text_type(_layer, default), do: default

  defp text_locator_offset(
         %{outgoing_link: %{target_layer_id: target_layer_id}} = layer,
         layer_lookup,
         axis
       )
       when not is_nil(target_layer_id) do
    case layer_lookup |> Map.get(target_layer_id) |> locator_anchor() do
      {x, _y} when axis == :x -> round(text_locator_center(layer, :x) - x)
      {_x, y} when axis == :y -> round(text_locator_center(layer, :y) - y)
      _ -> stored_text_locator_offset(layer, axis)
    end
  end

  defp text_locator_offset(layer, _layer_lookup, axis),
    do: stored_text_locator_offset(layer, axis)

  defp stored_text_locator_offset(%{outgoing_link: %{locator_offset_x: offset}}, :x)
       when is_integer(offset),
       do: offset

  defp stored_text_locator_offset(%{outgoing_link: %{locator_offset_y: offset}}, :y)
       when is_integer(offset),
       do: offset

  defp stored_text_locator_offset(_layer, _axis), do: 0

  defp text_locator_center(
         %{text: %{position_x: position_x, size_hint: %{width: width}}},
         :x
       )
       when is_number(position_x) and is_number(width),
       do: position_x + width / 2.0

  defp text_locator_center(
         %{text: %{position_y: position_y, size_hint: %{height: height}}},
         :y
       )
       when is_number(position_y) and is_number(height),
       do: position_y + height / 2.0

  defp text_locator_center(
         %{text: %{position_x: position_x} = text},
         :x
       )
       when is_number(position_x),
       do: position_x + measured_text_dimension(text, :width) / 2.0

  defp text_locator_center(
         %{text: %{position_y: position_y} = text},
         :y
       )
       when is_number(position_y),
       do: position_y + measured_text_dimension(text, :height) / 2.0

  defp measured_text_dimension(text, axis) do
    text
    |> measured_text_size()
    |> elem(if(axis == :width, do: 0, else: 1))
  end

  defp measured_text_size(text) do
    RenewCollab.TextMeasure.MeasureServer.measure(
      {font_family(text), font_style(text), font_size(text), text_lines(text)}
    )
  rescue
    _ -> {0, 0}
  catch
    :exit, _ -> {0, 0}
  end

  defp text_lines(%{body: body} = text) do
    body
    |> to_string()
    |> String.split("\n")
    |> Enum.filter(&(include_blank_lines?(text) or not blank?(&1)))
  end

  defp include_blank_lines?(%{style: %{blank_lines: blank_lines}}), do: blank_lines
  defp include_blank_lines?(_text), do: false

  defp font_style(%{style: %{} = text_style}) do
    [
      if(text_style.bold, do: 1, else: 0),
      if(text_style.italic, do: 2, else: 0)
    ]
    |> Enum.reduce(0, &Bitwise.bor/2)
  end

  defp font_style(_text), do: 0

  defp font_family(%{style: %{font_family: font_family}}) when is_binary(font_family),
    do: font_family

  defp font_family(_text), do: "sans-serif"

  defp font_size(%{style: %{font_size: font_size}}) when is_number(font_size),
    do: round(font_size)

  defp font_size(_text), do: 12

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()

  defp locator_anchor(%{box: %{position_x: x, position_y: y, width: width, height: height}})
       when is_number(x) and is_number(y) and is_number(width) and is_number(height),
       do: {x + width / 2.0, y + height / 2.0}

  defp locator_anchor(%{
         edge:
           %{source_x: source_x, source_y: source_y, target_x: target_x, target_y: target_y} =
             edge
       })
       when is_number(source_x) and is_number(source_y) and is_number(target_x) and
              is_number(target_y) do
    points =
      [{edge.source_x, edge.source_y}] ++
        ((edge.waypoints || []) |> Enum.map(&{&1.position_x, &1.position_y})) ++
        [{edge.target_x, edge.target_y}]

    {xs, ys} = Enum.unzip(points)

    {(Enum.min(xs) + Enum.max(xs)) / 2.0, (Enum.min(ys) + Enum.max(ys)) / 2.0}
  end

  defp locator_anchor(_layer), do: nil

  defp attach_synthetic_labels(orig_refs) do
    for {%Storable{class_name: class_name, fields: %{_gen_id: gen_id}}, index} <-
          Enum.with_index(orig_refs),
        class_name == "de.renew.gui.TransitionFigure" or
          class_name == "de.renew.gui.PlaceFigure",
        reduce: orig_refs do
      refs ->
        {refs, locator_base} =
          create_ref(refs, %Renewex.Storable{
            class_name: "CH.ifa.draw.standard.RelativeLocator",
            fields: %{
              fOffsetY: 0.5,
              fOffsetX: 0.5
            }
          })

        {refs, locator_ref} =
          create_ref(refs, %Renewex.Storable{
            class_name: "CH.ifa.draw.standard.OffsetLocator",
            fields: %{
              fOffsetY: 0,
              fOffsetX: 0,
              fBase: locator_base
            }
          })

        {refs, _} =
          create_ref(refs, %Renewex.Storable{
            class_name: "de.renew.gui.CPNTextFigure",
            fields: %{
              _root: true,
              attributes: %Renewex.Storable{
                class_name: "CH.ifa.draw.figures.FigureAttributes",
                fields: %{
                  attributes: [
                    {"Visible", "Boolean", true},
                    {"PetriStationSyntetic", "Boolean", true}
                  ]
                }
              },
              fOriginX: 0,
              fOriginY: 0,
              text: gen_id,
              fCurrentFontName: "monospaced",
              fCurrentFontStyle: 0,
              fCurrentFontSize: 2,
              fIsReadOnly: false,
              fParent: {:ref, index},
              fLocator: locator_ref,
              fType: 2
            }
          })

        refs
    end
  end

  defp export_attributes(:box, layer) do
    %Renewex.Storable{
      class_name: "CH.ifa.draw.figures.FigureAttributes",
      fields: %{
        attributes:
          [
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
            {"LineWidth", "Int", round(style_or_default(layer, :border_width))},
            {"LineStyle", "String", style_or_default(layer, :border_dash_array)}
          ] ++ export_target_location(layer)
      }
    }
  end

  defp export_attributes(:edge, %{edge: edge} = layer) do
    %Renewex.Storable{
      class_name: "CH.ifa.draw.figures.FigureAttributes",
      fields: %{
        attributes:
          [
            {"FrameColor", "Color",
             color_to_rgba(
               style_or_default(edge, :stroke_color),
               style_or_default(layer, :opacity)
             )},
            {"LineWidth", "Int", round(style_or_default(edge, :stroke_width))},
            {"LineStyle", "String", style_or_default(edge, :stroke_dash_array)},
            {"FillColor", "Color",
             color_to_rgba(
               style_or_default(layer, :background_color),
               style_or_default(layer, :opacity)
             )}
          ] ++ export_target_location(layer)
      }
    }
  end

  defp export_attributes(:text, layer) do
    with layer_style <- layer.style,
         text_style <- layer.text.style do
      %Renewex.Storable{
        class_name: "CH.ifa.draw.figures.FigureAttributes",
        fields: %{
          attributes:
            if(is_nil(text_style),
              do: [],
              else: [
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
                 )}
              ]
            )
            |> Enum.concat(
              if(is_nil(layer_style),
                do: [],
                else: [
                  {"FillColor", "Color",
                   color_to_rgba(
                     style(layer, :background_color),
                     style_or_default(layer, :opacity)
                   )},
                  {"FrameColor", "Color",
                   color_to_rgba(
                     style(layer, :border_color),
                     style_or_default(layer, :opacity)
                   )},
                  {"LineWidth", "Int", round(style_or_default(layer, :border_width))},
                  {"LineStyle", "String", style_or_default(layer, :border_dash_array)}
                ]
              )
            )
            |> Enum.concat(export_target_location(layer))
        }
      }
    end
  end

  defp export_target_location(%{style: %{target_location: target_location}})
       when is_binary(target_location) and target_location != "" do
    [{"targetLocation", "String", target_location}]
  end

  defp export_target_location(_layer), do: []

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
    [r, g, b, a] =
      Regex.run(@rgba_paren, args, capture: :all_but_first)
      |> Enum.map(&Float.parse/1)
      |> Enum.map(&elem(&1, 0))

    {:rgba, round(r), round(g), round(b), round(255 * a * opacity)}
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

    {:rgba, r, g, b, round(255 * opacity)}
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

  defp style(%{:style => nil}, _style_key) do
    nil
  end

  defp style(%{:style => style}, style_key) do
    with %{^style_key => value} <- style do
      value
    else
      _ -> nil
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
  defp default_style(:border_color), do: "black"
  defp default_style(:border_dash_array), do: ""
  defp default_style(:stroke_dash_array), do: ""
  defp default_style(:stroke_width), do: 1
  defp default_style(:stroke_color), do: "black"

  defp default_style(_style_key), do: nil

  defp create_ref(storables, nil), do: {storables, nil}

  defp create_ref(storables, %Storable{} = s),
    do: {Enum.concat(storables, [s]), {:ref, Enum.count(storables)}}

  defp bond_to_connector(bond, sockets) do
    sockets
    |> Map.get(bond.socket_id)
    |> Map.get(:socket_schema)
    |> Map.get(:stencil, :rect)
    |> case do
      :rect ->
        "CH.ifa.draw.standard.ChopBoxConnector"

      :ellipse ->
        "CH.ifa.draw.figures.ChopEllipseConnector"

      _ ->
        "CH.ifa.draw.standard.ChopBoxConnector"
    end
  end
end
