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

  def normalized_parenthoods(layers, parenthoods) do
    entries =
      parenthoods
      |> List.wrap()
      |> Enum.flat_map(&normalize_parenthood/1)

    self_entries =
      layers
      |> List.wrap()
      |> Enum.map(&value(&1, :id))
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&{&1, &1, 0})

    (self_entries ++ entries)
    |> Enum.uniq()
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
    |> update_existing(:box, &shift_box(&1, dx, dy))
    |> update_existing(:text, &shift_text(&1, dx, dy))
    |> update_existing(:edge, &shift_edge(&1, dx, dy))
  end

  defp shift_box(nil, _dx, _dy), do: nil

  defp shift_box(%{} = box, dx, dy) do
    box
    |> shift_number(:position_x, dx)
    |> shift_number(:position_y, dy)
  end

  defp shift_box(box, _dx, _dy), do: box

  defp shift_text(nil, _dx, _dy), do: nil

  defp shift_text(%{} = text, dx, dy) do
    text
    |> shift_number(:position_x, dx)
    |> shift_number(:position_y, dy)
    |> update_existing(:size_hint, &shift_size_hint(&1, dx, dy))
  end

  defp shift_text(text, _dx, _dy), do: text

  defp shift_edge(nil, _dx, _dy), do: nil

  defp shift_edge(%{} = edge, dx, dy) do
    edge
    |> shift_number(:source_x, dx)
    |> shift_number(:source_y, dy)
    |> shift_number(:target_x, dx)
    |> shift_number(:target_y, dy)
    |> update_waypoints(dx, dy)
  end

  defp shift_edge(edge, _dx, _dy), do: edge

  defp update_waypoints(edge, dx, dy) do
    case value(edge, :waypoints) do
      nil ->
        edge

      waypoints ->
        put_value(edge, :waypoints, Enum.map(List.wrap(waypoints), &shift_waypoint(&1, dx, dy)))
    end
  end

  defp shift_waypoint(%{} = waypoint, dx, dy) do
    waypoint
    |> shift_number(:position_x, dx)
    |> shift_number(:position_y, dy)
  end

  defp shift_waypoint(waypoint, _dx, _dy), do: waypoint

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

  defp update_existing(%{} = map, key, updater) when is_atom(key) do
    string_key = Atom.to_string(key)

    cond do
      Map.has_key?(map, key) -> Map.update!(map, key, updater)
      Map.has_key?(map, string_key) -> Map.update!(map, string_key, updater)
      true -> map
    end
  end

  defp update_existing(map, _key, _updater), do: map

  defp put_value(%{} = map, key, value) when is_atom(key) do
    string_key = Atom.to_string(key)

    cond do
      Map.has_key?(map, key) -> Map.put(map, key, value)
      Map.has_key?(map, string_key) -> Map.put(map, string_key, value)
      true -> Map.put(map, key, value)
    end
  end

  defp put_value(%{} = map, key, value), do: Map.put(map, key, value)

  defp shift_number(%{} = map, key, delta) do
    case value(map, key) do
      value when is_number(value) -> put_value(map, key, value + delta)
      _ -> map
    end
  end

  defp number(value) when is_number(value), do: value
  defp number(_), do: 0

  defp nested_descendant(parenthood) do
    case value(parenthood, :depth) do
      depth when is_integer(depth) and depth > 0 -> [value(parenthood, :descendant_id)]
      _ -> []
    end
  end

  defp normalize_parenthood({ancestor_id, descendant_id, depth})
       when not is_nil(ancestor_id) and not is_nil(descendant_id) and is_integer(depth),
       do: [{ancestor_id, descendant_id, depth}]

  defp normalize_parenthood(%{} = parenthood) do
    case {value(parenthood, :ancestor_id), value(parenthood, :descendant_id),
          value(parenthood, :depth)} do
      {ancestor_id, descendant_id, depth}
      when not is_nil(ancestor_id) and not is_nil(descendant_id) and is_integer(depth) ->
        [{ancestor_id, descendant_id, depth}]

      _ ->
        []
    end
  end

  defp normalize_parenthood(_), do: []

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

  defp shift_size_hint(%{} = size_hint, dx, dy) do
    size_hint
    |> shift_number(:position_x, dx)
    |> shift_number(:position_y, dy)
  end

  defp shift_size_hint(size_hint, _dx, _dy), do: size_hint
end
