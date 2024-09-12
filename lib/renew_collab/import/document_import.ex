defmodule RenewCollab.Import.DocumentImport do
  def import(name, content) do
    symbol_ids = RenewCollab.Symbol.ids_by_name()

    with {:ok, true} <- check_utf8_binary?(content),
         {:ok, %Renewex.Document{root: root, refs: refs}} <- Renewex.parse_document(content),
         parser <- Renewex.Parser.detect_document_version(Renewex.Tokenizer.scan(content)),
         %Renewex.Storable{class_name: class_name, fields: %{figures: figures}} <- root do
      refs_with_ids = Enum.map(refs, fn s -> {s, generate_layer_id()} end) |> Enum.to_list()

      figs =
        figures
        |> Enum.with_index()
        |> Enum.flat_map(fn {fig, i} -> collect_nested_figures(fig, i, refs_with_ids) end)

      unique_figs =
        figs
        |> Enum.group_by(fn {{_, uid}, _} -> uid end)
        |> Enum.map(fn {uid, [first | _]} -> first end)

      hierarchy = Enum.flat_map(figures, fn fig -> collect_hierarchy(fig, refs_with_ids) end)

      # FrameColor
      # FillColor
      # TextColor
      # TextAlignment
      # ArrowMode
      # FontName
      # LineWidth
      # LineStyle
      # FontSize
      # FontStyle
      # LineShape
      # BSplineSegments
      # BSplineDegree
      # ArcScale
      layers =
        for layer <- unique_figs do
          case layer do
            {{%Renewex.Storable{
                class_name: class_name,
                fields: %{x: x, y: y, w: w, h: h} = fields
              }, uuid}, z_index} ->
              attrs =
                with %Renewex.Storable{fields: f} <- Map.get(fields, :attributes) do
                  f.attributes |> Enum.into(%{}, fn {key, _type, value} -> {key, value} end)
                else
                  _ -> nil
                end

              style =
                case attrs do
                  nil ->
                    nil

                  attrs ->
                    %{
                      "opacity" => Map.get(attrs, "Opacity", 1),
                      "background_color" => convert_color(Map.get(attrs, "FillColor", "#70DB93")),
                      "border_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                      "border_width" => convert_border_width(Map.get(attrs, "LineWidth", 1))
                    }
                end

              {shape_name, shape_attributes} =
                convert_shape(parser.grammar, class_name, fields, attrs)

              %{
                "semantic_tag" => class_name,
                "z_index" => z_index,
                "hidden" => convert_visibility_to_hidden(Map.get(attrs, "Visibility")),
                "id" => uuid,
                "box" => %{
                  "position_x" => x,
                  "position_y" => y,
                  "width" => w,
                  "height" => h,
                  "symbol_shape_attributes" => shape_attributes,
                  "symbol_shape_id" => Map.get(symbol_ids, shape_name)
                },
                "style" => style
              }

            {{%Renewex.Storable{
                class_name: class_name,
                fields: %{text: body, fOriginX: x, fOriginY: y} = fields
              }, uuid}, z_index} ->
              attrs =
                with %Renewex.Storable{fields: f} <- Map.get(fields, :attributes) do
                  f.attributes |> Enum.into(%{}, fn {key, _type, value} -> {key, value} end)
                else
                  _ -> nil
                end

              style =
                case attrs do
                  nil ->
                    nil

                  attrs ->
                    %{
                      "opacity" => Map.get(attrs, "Opacity", 1),
                      "background_color" => convert_color(Map.get(attrs, "FillColor", "#70DB93")),
                      "border_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                      "border_width" => convert_border_width(Map.get(attrs, "LineWidth", 1)),
                      "border_dash_array" => convert_line_style(Map.get(attrs, "LineStyle"))
                    }
                end

              %{
                "semantic_tag" => class_name,
                "z_index" => z_index,
                "hidden" => convert_visibility_to_hidden(Map.get(attrs, "Visibility")),
                "id" => uuid,
                "style" => style,
                "text" => %{
                  "position_x" => x,
                  "position_y" => y,
                  "body" => body,
                  "style" => %{
                    "underline" =>
                      convert_font_style(Map.get(fields, :fCurrentFontStyle, 0), :underlined),
                    "alignment" => convert_alignment(Map.get(attrs, "TextAlignment", 0)),
                    "font_size" => Map.get(fields, :fCurrentFontSize, 12),
                    "font_family" =>
                      convert_font(Map.get(fields, :fCurrentFontName, "sans-serif")),
                    "bold" => convert_font_style(Map.get(fields, :fCurrentFontStyle, 0), :bold),
                    "italic" =>
                      convert_font_style(Map.get(fields, :fCurrentFontStyle, 0), :italic),
                    "text_color" => convert_color(Map.get(attrs, "TextColor", "black"))
                  }
                }
              }

            {{%Renewex.Storable{
                class_name: class_name,
                fields: %{points: [_, _ | _] = points} = fields
              }, uuid}, z_index} ->
              start_point = hd(points)
              end_point = List.last(points)
              start_x = start_point[:x]
              start_y = start_point[:y]
              end_x = end_point[:x]
              end_y = end_point[:y]

              attrs =
                with %Renewex.Storable{fields: f} <- Map.get(fields, :attributes) do
                  f.attributes |> Enum.into(%{}, fn {key, _type, value} -> {key, value} end)
                else
                  _ -> nil
                end

              style =
                case attrs do
                  nil ->
                    nil

                  attrs ->
                    %{
                      "opacity" => Map.get(attrs, "Opacity", 1),
                      "background_color" => convert_color(Map.get(attrs, "FillColor", "#70DB93")),
                      "border_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                      "border_width" => convert_border_width(Map.get(attrs, "LineWidth", 1))
                    }
                end

              line_style =
                case attrs do
                  nil ->
                    nil

                  attrs ->
                    %{
                      "stroke_width" => convert_border_width(Map.get(attrs, "LineWidth", 1)),
                      "stroke_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                      "stroke_join" => "rect",
                      "stroke_cap" => "rect",
                      "stroke_dash_array" => convert_line_style(Map.get(attrs, "LineStyle")),
                      "source_tip" =>
                        convert_line_decoration(
                          resolve_ref(refs, Map.get(fields, :start_decoration))
                        ),
                      "target_tip" =>
                        convert_line_decoration(
                          resolve_ref(refs, Map.get(fields, :end_decoration))
                        ),
                      "smoothness" => ""
                    }
                end

              %{
                "semantic_tag" => class_name,
                "z_index" => z_index,
                "hidden" => convert_visibility_to_hidden(Map.get(attrs, "Visibility")),
                "id" => uuid,
                "style" => style,
                "edge" => %{
                  "source_x" => start_x,
                  "source_y" => start_y,
                  "target_x" => end_x,
                  "target_y" => end_y,
                  "cyclic" => convert_line_cyclicity(parser.grammar, class_name),
                  "waypoints" =>
                    points
                    |> Enum.drop(1)
                    |> Enum.drop(-1)
                    |> Enum.with_index()
                    |> Enum.map(fn {p, index} ->
                      %{
                        "sort" => index,
                        "position_x" => p[:x],
                        "position_y" => p[:y]
                      }
                    end),
                  "style" => line_style
                }
              }

            {{%Renewex.Storable{
                class_name: class_name
              }, uuid}, z_index} ->
              %{
                "semantic_tag" => class_name,
                "z_index" => z_index,
                "id" => uuid
              }
          end
        end

      {:ok, %{"name" => name, "kind" => class_name, "layers" => layers}, hierarchy}
    end
  end

  defp convert_color(m) when is_binary(m), do: m
  defp convert_color({:rgba, 255, 199, 158, 255}), do: "transparent"
  defp convert_color({:rgb, 255, 199, 158}), do: "transparent"

  defp convert_color({:rgba, r, g, b, a}) when is_integer(a),
    do: "rgba(#{r},#{g},#{b},#{a / 250.0})"

  defp convert_color({:rgba, r, g, b, a}) when is_float(a) and a <= 1.0,
    do: "rgba(#{r},#{g},#{b},#{a})"

  defp convert_color({:rgb, r, g, b}), do: "rgb(#{r},#{g},#{b})"

  defp convert_alignment(0), do: :left
  defp convert_alignment(1), do: :center
  defp convert_alignment(2), do: :right
  defp convert_alignment(_), do: :left

  defp convert_font_style(bitmask, :underlined), do: Bitwise.band(bitmask, 4) == 4
  defp convert_font_style(bitmask, :bold), do: Bitwise.band(bitmask, 1) == 1
  defp convert_font_style(bitmask, :italic), do: Bitwise.band(bitmask, 2) == 2

  defp convert_font("SansSerif"), do: "sans-serif"
  defp convert_font("Serif"), do: "serif"
  defp convert_font(other), do: other

  defp convert_line_style(gap) when is_integer(gap), do: Integer.to_string(gap)
  defp convert_line_style(dasharray) when is_binary(dasharray), do: dasharray
  defp convert_line_style(nil), do: nil

  defp convert_border_width(width) when is_integer(width), do: Integer.to_string(width)
  defp convert_border_width(width) when is_binary(width), do: width
  defp convert_border_width(nil), do: nil

  defp convert_line_decoration(nil), do: nil

  defp convert_line_decoration(%Renewex.Storable{
         class_name: class_name,
         fields: %{
           angle: angle,
           outer_radius: outer_radius,
           inner_radius: inner_radius,
           filled: filled
         }
       }) do
    "#{class_name}(#{angle}:#{outer_radius}:#{inner_radius}:#{filled})"
  end

  defp convert_line_decoration(%Renewex.Storable{
         class_name: "de.renew.gui.CircleDecoration" = class_name
       }) do
    "#{class_name}"
  end

  defp convert_line_decoration(other), do: dbg(other)

  defp convert_visibility_to_hidden(visible) when is_boolean(visible), do: not visible
  defp convert_visibility_to_hidden(nil), do: false
  defp convert_visibility_to_hidden(_), do: false

  defp resolve_ref(refs, {:ref, r}), do: Enum.at(refs, r)
  defp resolve_ref(_, nil), do: nil
  defp resolve_ref(_, noref), do: noref

  defp convert_line_cyclicity(grammar, class_name) do
    Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.contrib.PolygonFigure")
  end

  defp convert_shape(grammar, class_name, fields, attrs) do
    cond do
      Renewex.Hierarchy.is_subtype_of(
        grammar,
        class_name,
        "de.renew.bpmn.figures.DataStoreFigure"
      ) ->
        {"database", nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "de.renew.bpmn.figures.DataFigure") ->
        {case Map.get(fields, :type) do
           0 -> "rect-fold-paper-proportional"
           1 -> "rect-fold-paper-proportional-arrow-right"
           2 -> "rect-fold-paper-proportional-arrow-right-black"
           3 -> "rect-fold-paper-proportional-striped"
         end, nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "de.renew.bpmn.figures.ActivityFigure") ->
        {case Map.get(fields, :type) do
           0 -> "bpmn-activity"
           1 -> "bpmn-activity-exchange"
         end,
         %{
           "rx" => 5,
           "ry" => 5
         }}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "de.renew.bpmn.figures.GatewayFigure") ->
        {case Map.get(fields, :type) do
           0 -> "bpmn-gateway"
           1 -> "bpmn-gateway-xor"
           2 -> "bpmn-gateway-and"
         end, nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "de.renew.bpmn.figures.EventFigure") ->
        {case {Map.get(fields, :position), Map.get(fields, :type), Map.get(fields, :throwing)} do
           {0, 0, false} -> "bpmn-start-standard"
           {0, 0, true} -> "bpmn-start-standard-throwing"
           {0, 1, false} -> "bpmn-start-message"
           {0, 1, true} -> "bpmn-start-message-throwing"
           {0, 2, false} -> "bpmn-start-terminate"
           {0, 2, true} -> "bpmn-start-terminate-throwing"
           {1, 0, false} -> "bpmn-interm-standard"
           {1, 0, true} -> "bpmn-interm-standard-throwing"
           {1, 1, false} -> "bpmn-interm-message"
           {1, 1, true} -> "bpmn-interm-message-throwing"
           {1, 2, false} -> "bpmn-interm-terminate"
           {1, 2, true} -> "bpmn-interm-terminate-throwing"
           {2, 0, false} -> "bpmn-end-standard"
           {2, 0, true} -> "bpmn-end-standard-throwing"
           {2, 1, false} -> "bpmn-end-message"
           {2, 1, true} -> "bpmn-end-message-throwing"
           {2, 2, false} -> "bpmn-end-terminate"
           {2, 2, true} -> "bpmn-end-terminate-throwing"
         end, nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "de.renew.bpmn.figures.PoolFigure") ->
        {"bpmn-pool", nil}

      Renewex.Hierarchy.is_subtype_of(
        grammar,
        class_name,
        "de.renew.diagram.RoleDescriptorFigure"
      ) ->
        {"rect", nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "de.renew.diagram.VJoinFigure") ->
        # fields.decoration.class_name == de.renew.diagram.XORDecoration
        # fields.decoration.class_name == de.renew.diagram.ANDDecoration
        {"bar-horizontal-black-diamond-quad", nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "de.renew.diagram.VSplitFigure") ->
        {"bar-horizontal-black-diamond-quad", nil}

      Renewex.Hierarchy.is_subtype_of(
        grammar,
        class_name,
        "de.renew.interfacenets.datatypes.InterfaceBoxFigure"
      ) ->
        {"bracket-both-outer", nil}

      Renewex.Hierarchy.is_subtype_of(
        grammar,
        class_name,
        "de.renew.interfacenets.datatypes.InterfaceFigure"
      ) ->
        {if Map.get(attrs, "RightInterface") do
           "bracket-right-outer"
         else
           "bracket-left-outer"
         end, nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.contrib.TriangleFigure") ->
        {case Map.get(fields, :rotation) do
           0 -> "triangle-up"
           1 -> "triangle-ne"
           2 -> "triangle-right"
           3 -> "triangle-se"
           4 -> "triangle-down"
           5 -> "triangle-sw"
           6 -> "triangle-left"
           7 -> "triangle-nw"
         end, nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.contrib.DiamondFigure") ->
        {"diamond", nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.figures.EllipseFigure") ->
        {"ellipse", nil}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.figures.PieFigure") ->
        # "pie:#{Map.get(fields, :start_angle)}:#{Map.get(fields, :end_angle)}"
        {"pie",
         %{
           "start_angle" => Map.get(fields, :start_angle),
           "end_angle" => Map.get(fields, :end_angle)
         }}

      Renewex.Hierarchy.is_subtype_of(
        grammar,
        class_name,
        "CH.ifa.draw.figures.RoundRectangleFigure"
      ) ->
        # "roundrect:#{Map.get(fields, :arc_width, 0)}:#{Map.get(fields, :arc_height, 0)}"
        {"rect-round",
         %{
           "rx" => Map.get(fields, :arc_width, 0),
           "ry" => Map.get(fields, :arc_height, 0)
         }}

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.figures.RectangleFigure") ->
        {"rect", nil}

      true ->
        {dbg(class_name), nil}
    end
  end

  defp collect_nested_figures({:ref, r}, index, refs_with_ids) do
    case Enum.at(refs_with_ids, r) do
      {%Renewex.Storable{class_name: class_name, fields: %{figures: figures}}, _} = el ->
        figures
        |> Enum.with_index()
        |> Enum.flat_map(fn {fig, i} ->
          collect_nested_figures(fig, i, refs_with_ids)
        end)
        |> then(
          &Enum.concat(
            [{el, index}],
            &1
          )
        )
        |> Enum.to_list()

      {%Renewex.Storable{}, _} = el ->
        [{el, index}]

      _ ->
        []
    end
  end

  defp collect_hierarchy({:ref, r}, refs_with_ids, ancestors \\ []) do
    case Enum.at(refs_with_ids, r) do
      {%Renewex.Storable{class_name: class_name, fields: %{figures: figures}}, own_id} = el ->
        figures
        |> Enum.flat_map(fn fig ->
          collect_hierarchy(
            fig,
            refs_with_ids,
            [
              {own_id, 0}
              | Enum.map(ancestors, fn
                  {parent_id, distance} -> {parent_id, distance + 1}
                end)
            ]
          )
        end)
        |> Enum.concat([{own_id, own_id, 0}])
        |> Enum.concat(
          Enum.map(ancestors, fn
            {parent_id, distance} -> {parent_id, own_id, distance + 1}
          end)
        )
        |> Enum.to_list()

      {%Renewex.Storable{}, child_id} = el ->
        Enum.map(ancestors, fn
          {parent_id, distance} -> {parent_id, child_id, distance + 1}
        end)
        |> Enum.concat([{child_id, child_id, 0}])

      _ ->
        []
    end
  end

  def generate_layer_id() do
    Ecto.UUID.generate()
  end

  defp check_utf8_binary?(binary) do
    if :unicode.characters_to_binary(binary, :utf8, :utf8) == binary do
      {:ok, true}
    else
      {:ok, false}
    end
  end
end