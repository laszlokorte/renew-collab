defmodule RenewCollab.Import.DocumentImport do
  def import(name, content) do
    with {:ok, true} <- check_utf8_binary?(content),
         {:ok, root, refs} <- Renewex.parse_string(content),
         parser <- Renewex.Parser.detect_document_version(Renewex.Tokenizer.scan(content)),
         %Renewex.Storable{class_name: class_name, fields: %{figures: figures}} <- root do
      refs_with_ids = Enum.map(refs, fn s -> {s, generate_layer_id()} end) |> Enum.to_list()

      figs = Enum.flat_map(figures, fn fig -> collect_nested_figures(fig, refs_with_ids) end)
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
        for layer <- figs do
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
                      "background_color" => convert_color(Map.get(attrs, "FillColor", "green")),
                      "border_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                      "border_width" => Map.get(attrs, "LineWidth", "1")
                    }
                end

              %{
                "semantic_tag" => class_name,
                "z_index" => z_index,
                "id" => uuid,
                "box" => %{
                  "position_x" => x,
                  "position_y" => y,
                  "width" => w,
                  "height" => h,
                  "shape" => convert_shape(parser.grammar, class_name, fields)
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
                      "background_color" => convert_color(Map.get(attrs, "FillColor", "green")),
                      "border_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                      "border_width" => Map.get(attrs, "LineWidth", "1")
                    }
                end

              %{
                "semantic_tag" => class_name,
                "z_index" => z_index,
                "id" => uuid,
                "style" => style,
                "text" => %{
                  "position_x" => x,
                  "position_y" => y,
                  "body" => body,
                  "style" => %{
                    "underline" => false,
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
                      "opacity" => Map.get(attrs, "Opacity", 1)
                    }
                end

              line_style =
                case attrs do
                  nil ->
                    nil

                  attrs ->
                    %{
                      "stroke_width" => Map.get(attrs, "LineWidth", "1"),
                      "stroke_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                      "stroke_joint" => "round",
                      "stroke_cap" => "round",
                      "stroke_dash_array" => convert_line_style(Map.get(attrs, "LineStyle")),
                      "source_tip" => "",
                      "target_tip" => "",
                      "smoothness" => ""
                    }
                end

              %{
                "semantic_tag" => class_name,
                "z_index" => z_index,
                "id" => uuid,
                "style" => style,
                "edge" => %{
                  "source_x" => start_x,
                  "source_y" => start_y,
                  "target_x" => end_x,
                  "target_y" => end_y,
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
  defp convert_color({:rgba, r, g, b, a}), do: "rgba(#{r},#{g},#{b},#{a})"
  defp convert_color({:rgb, r, g, b}), do: "rgb(#{r},#{g},#{b})"

  defp convert_alignment(0), do: :left
  defp convert_alignment(1), do: :center
  defp convert_alignment(2), do: :right
  defp convert_alignment(_), do: :left

  defp convert_font_style(1, :bold), do: true
  defp convert_font_style(2, :italic), do: true
  defp convert_font_style(_, :bold), do: false
  defp convert_font_style(_, :italic), do: false

  defp convert_font("SansSerif"), do: "sans-serif"
  defp convert_font("Serif"), do: "serif"
  defp convert_font(other), do: other

  defp convert_line_style(gap) when is_integer(gap), do: Integer.to_string(gap)
  defp convert_line_style(nil), do: nil
  defp convert_line_style(dasharray) when is_binary(dasharray), do: dasharray

  defp convert_shape(grammar, class_name, fields) do
    cond do
      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.contrib.TriangleFigure") ->
        "triangle:#{Map.get(fields, :rotation)}"

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.contrib.DiamondFigure") ->
        "diamond"

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.figures.EllipseFigure") ->
        "ellipse"

      Renewex.Hierarchy.is_subtype_of(
        grammar,
        class_name,
        "CH.ifa.draw.figures.RoundRectangleFigure"
      ) ->
        "roundrect:#{Map.get(fields, :arc_width, 0)}:#{Map.get(fields, :arc_height, 0)}"

      Renewex.Hierarchy.is_subtype_of(grammar, class_name, "CH.ifa.draw.figures.RectangleFigure") ->
        "rect"

      true ->
        nil
    end
  end

  defp collect_nested_figures({:ref, r}, refs_with_ids) do
    case Enum.at(refs_with_ids, r) do
      {%Renewex.Storable{class_name: class_name, fields: %{figures: figures}}, _} = el ->
        figures
        |> Enum.flat_map(fn fig ->
          collect_nested_figures(fig, refs_with_ids)
        end)
        |> then(
          &Enum.concat(
            Enum.with_index([el]),
            &1
          )
        )
        |> Enum.to_list()

      {%Renewex.Storable{}, _} = el ->
        [el]
        |> Enum.to_list()
        |> Enum.with_index()

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
