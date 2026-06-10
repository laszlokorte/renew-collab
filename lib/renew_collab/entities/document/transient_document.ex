defmodule RenewCollab.Document.TransientDocument do
  @default_name "Untitled"

  defstruct [:content, :parenthoods, :hyperlinks, :bonds, :thumbnail]

  def update_name(%__MODULE__{content: content} = doc, updater) do
    %__MODULE__{doc | content: Map.update(content, :name, @default_name, updater)}
  end

  def ensure_text_size_hints(%__MODULE__{content: content} = doc) do
    %__MODULE__{
      doc
      | content:
          Map.update(content, :layers, [], fn layers ->
            Enum.map(layers, &ensure_layer_text_size_hint/1)
          end)
    }
  end

  def origin(%__MODULE__{content: %{layers: layers}}), do: layers_origin(layers)
  def origin(_), do: %{"x" => 0, "y" => 0}

  def layers_origin(layers) do
    case layers_bounds(layers) do
      nil -> %{"x" => 0, "y" => 0}
      %{min_x: x, min_y: y} -> %{"x" => x, "y" => y}
    end
  end

  def layers_bounds(layers) do
    layers
    |> List.wrap()
    |> Enum.flat_map(&layer_points/1)
    |> case do
      [] ->
        nil

      points ->
        %{
          min_x: points |> Enum.map(& &1.x) |> Enum.min(),
          min_y: points |> Enum.map(& &1.y) |> Enum.min()
        }
    end
  end

  def root_layer_ids(%__MODULE__{content: %{layers: layers}, parenthoods: parenthoods}) do
    root_layer_ids(layers, parenthoods)
  end

  def root_layer_ids(layers, parenthoods) do
    layer_ids =
      layers
      |> List.wrap()
      |> Enum.map(&value(&1, :id))
      |> Enum.reject(&is_nil/1)
      |> MapSet.new()

    nested_ids =
      parenthoods
      |> List.wrap()
      |> Enum.flat_map(fn
        {_, descendant_id, depth} when depth > 0 -> [descendant_id]
        %{} = parenthood -> nested_descendant(parenthood)
        _ -> []
      end)
      |> MapSet.new()

    layer_ids
    |> MapSet.difference(nested_ids)
    |> Enum.into([])
  end

  def shift_positions(%__MODULE__{content: content} = doc, dx, dy) do
    %__MODULE__{
      doc
      | content:
          Map.update(content, :layers, [], &Enum.map(&1, fn l -> shift_layer(l, dx, dy) end))
    }
  end

  def shift_layer(layer, dx, dy) do
    layer
    |> Map.update(:box, nil, fn
      nil ->
        nil

      box = %{position_x: old_x, position_y: old_y} ->
        %{box | position_x: old_x + dx, position_y: old_y + dy}
    end)
    |> Map.update(:text, nil, fn
      nil ->
        nil

      text = %{position_x: old_x, position_y: old_y} ->
        text
        |> Map.put(:position_x, old_x + dx)
        |> Map.put(:position_y, old_y + dy)
        |> Map.update(:size_hint, nil, &shift_size_hint(&1, dx, dy))
    end)
    |> Map.update(
      :edge,
      nil,
      fn
        nil ->
          nil

        edge = %{
          source_x: old_sx,
          source_y: old_sy,
          target_x: old_tx,
          target_y: old_ty,
          waypoints: waypoints
        } ->
          %{
            edge
            | source_x: old_sx + dx,
              source_y: old_sy + dy,
              target_x: old_tx + dx,
              target_y: old_ty + dy,
              waypoints:
                waypoints
                |> Enum.map(fn
                  wp = %{position_x: px, position_y: py} ->
                    %{wp | position_x: px + dx, position_y: py + dy}
                end)
          }
      end
    )
  end

  defp layer_points(layer) do
    box_points(value(layer, :box)) ++
      text_points(value(layer, :text)) ++ edge_points(value(layer, :edge))
  end

  defp box_points(nil), do: []

  defp box_points(box) do
    x = number(value(box, :position_x))
    y = number(value(box, :position_y))
    width = number(value(box, :width))
    height = number(value(box, :height))

    [
      %{x: x, y: y},
      %{x: x + width, y: y + height}
    ]
  end

  defp text_points(nil), do: []

  defp text_points(text) do
    point = %{x: number(value(text, :position_x)), y: number(value(text, :position_y))}

    case value(text, :size_hint) do
      nil ->
        [point]

      hint ->
        x = number(value(hint, :position_x))
        y = number(value(hint, :position_y))
        width = number(value(hint, :width))
        height = number(value(hint, :height))

        [
          point,
          %{x: x, y: y},
          %{x: x + width, y: y + height}
        ]
    end
  end

  defp edge_points(nil), do: []

  defp edge_points(edge) do
    points = [
      %{x: number(value(edge, :source_x)), y: number(value(edge, :source_y))},
      %{x: number(value(edge, :target_x)), y: number(value(edge, :target_y))}
    ]

    waypoint_points =
      edge
      |> value(:waypoints, [])
      |> List.wrap()
      |> Enum.map(fn waypoint ->
        %{x: number(value(waypoint, :position_x)), y: number(value(waypoint, :position_y))}
      end)

    points ++ waypoint_points
  end

  defp value(map, key, default \\ nil)

  defp value(%{} = map, key, default) when is_atom(key) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end

  defp value(%{} = map, key, default), do: Map.get(map, key, default)
  defp value(_, _, default), do: default

  defp number(value) when is_number(value), do: value
  defp number(_), do: 0

  defp nested_descendant(parenthood) do
    case value(parenthood, :depth) do
      depth when is_integer(depth) and depth > 0 -> [value(parenthood, :descendant_id)]
      _ -> []
    end
  end

  defp ensure_layer_text_size_hint(layer) do
    Map.update(layer, :text, nil, fn
      nil ->
        nil

      text ->
        if value(text, :size_hint) do
          text
        else
          Map.put(text, :size_hint, measure_text_size_hint(text))
        end
    end)
  end

  defp measure_text_size_hint(text) do
    {width, height} =
      RenewCollab.TextMeasure.MeasureServer.measure({
        font_family(text),
        font_style(text),
        font_size(text),
        text_lines(text)
      })

    %{
      position_x: number(value(text, :position_x)),
      position_y: number(value(text, :position_y)),
      width: width * 1.0,
      height: height * 1.0
    }
  rescue
    _ ->
      fallback_text_size_hint(text)
  catch
    :exit, _ ->
      fallback_text_size_hint(text)
  end

  defp fallback_text_size_hint(text) do
    font_size = font_size(text)
    lines = text_lines(text)

    %{
      position_x: number(value(text, :position_x)),
      position_y: number(value(text, :position_y)),
      width: (lines |> Enum.map(&String.length/1) |> Enum.max(fn -> 1 end)) * font_size * 0.6,
      height: Enum.max([Enum.count(lines), 1]) * font_size * 1.2
    }
  end

  defp text_lines(text) do
    text
    |> value(:body, "")
    |> to_string()
    |> String.split("\n")
    |> Enum.filter(&(include_blank_lines?(text) or not blank?(&1)))
  end

  defp include_blank_lines?(text) do
    case value(text, :style) do
      nil -> false
      style -> value(style, :blank_lines, false)
    end
  end

  defp font_style(text) do
    case value(text, :style) do
      nil ->
        0

      style ->
        [
          if(value(style, :bold, false), do: 1, else: 0),
          if(value(style, :italic, false), do: 2, else: 0)
        ]
        |> Enum.reduce(0, &Bitwise.bor/2)
    end
  end

  defp font_family(text) do
    case value(text, :style) do
      nil -> "sans-serif"
      style -> value(style, :font_family, "sans-serif")
    end
  end

  defp font_size(text) do
    size =
      case value(text, :style) do
        nil -> 12
        style -> value(style, :font_size, 12)
      end

    case size do
      size when is_number(size) and size > 0 -> size
      _ -> 12
    end
  end

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()

  defp shift_size_hint(nil, _dx, _dy), do: nil

  defp shift_size_hint(%{position_x: old_x, position_y: old_y} = size_hint, dx, dy) do
    size_hint
    |> Map.put(:position_x, old_x + dx)
    |> Map.put(:position_y, old_y + dy)
  end

  defp shift_size_hint(size_hint, _dx, _dy), do: size_hint
end
