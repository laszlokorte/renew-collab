defmodule RenewCollab.Document.LayerClipboard do
  alias RenewCollab.Document.TransientDocument

  def encode(%TransientDocument{
        content: %{layers: layers},
        parenthoods: parenthoods,
        hyperlinks: hyperlinks,
        bonds: bonds
      }) do
    %{
      "format" => "renewex/layers",
      "version" => 1,
      "layers" => layers,
      "hierarchy" =>
        Enum.map(parenthoods, fn {ancestor_id, descendant_id, depth} ->
          %{
            "ancestor_id" => ancestor_id,
            "descendant_id" => descendant_id,
            "depth" => depth
          }
        end),
      "hyperlinks" => hyperlinks,
      "bonds" => bonds,
      "root_layer_ids" => root_layer_ids(layers, parenthoods),
      "origin" => origin(layers)
    }
  end

  def decode(%{} = clipboard) do
    layers = clipboard |> value(:layers, []) |> List.wrap()
    hierarchy = clipboard |> value(:hierarchy, []) |> List.wrap()
    hyperlinks = clipboard |> value(:hyperlinks, []) |> List.wrap()
    bonds = clipboard |> value(:bonds, []) |> List.wrap()

    id_map =
      layers
      |> Enum.map(&value(&1, :id))
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Map.new(fn id -> {id, Ecto.UUID.generate()} end)

    remapped_layers =
      layers
      |> Enum.map(fn layer ->
        old_id = value(layer, :id)

        layer
        |> deep_atomize()
        |> Map.put(:id, Map.get(id_map, old_id))
      end)
      |> Enum.reject(&is_nil(&1.id))

    remapped_hierarchy =
      hierarchy
      |> Enum.map(&remap_hierarchy(&1, id_map))
      |> Enum.reject(&is_nil/1)

    remapped_hyperlinks =
      hyperlinks
      |> Enum.map(&remap_hyperlink(&1, id_map))
      |> Enum.reject(&is_nil/1)

    remapped_bonds =
      bonds
      |> Enum.map(&remap_bond(&1, id_map))
      |> Enum.reject(&is_nil/1)

    root_layer_ids =
      clipboard
      |> value(:root_layer_ids, root_layer_ids(layers, hierarchy))
      |> List.wrap()
      |> Enum.map(&Map.get(id_map, &1))
      |> Enum.reject(&is_nil/1)

    {:ok,
     {%TransientDocument{
        content: %{layers: remapped_layers},
        parenthoods: remapped_hierarchy,
        hyperlinks: remapped_hyperlinks,
        bonds: remapped_bonds,
        thumbnail: nil
      }, origin(layers), root_layer_ids}}
  end

  defp remap_hierarchy(%{} = parenthood, id_map) do
    ancestor_id = value(parenthood, :ancestor_id) |> then(&Map.get(id_map, &1))
    descendant_id = value(parenthood, :descendant_id) |> then(&Map.get(id_map, &1))
    depth = value(parenthood, :depth)

    if ancestor_id && descendant_id && is_integer(depth) do
      {ancestor_id, descendant_id, depth}
    end
  end

  defp remap_hierarchy([ancestor_id, descendant_id, depth], id_map) do
    ancestor_id = Map.get(id_map, ancestor_id)
    descendant_id = Map.get(id_map, descendant_id)

    if ancestor_id && descendant_id && is_integer(depth) do
      {ancestor_id, descendant_id, depth}
    end
  end

  defp remap_hierarchy(_, _id_map), do: nil

  defp remap_hyperlink(%{} = hyperlink, id_map) do
    hyperlink = deep_atomize(hyperlink)
    source_layer_id = Map.get(id_map, hyperlink.source_layer_id)
    target_layer_id = Map.get(id_map, hyperlink.target_layer_id)

    if source_layer_id && target_layer_id do
      hyperlink
      |> Map.put(:source_layer_id, source_layer_id)
      |> Map.put(:target_layer_id, target_layer_id)
    end
  end

  defp remap_hyperlink(_, _id_map), do: nil

  defp remap_bond(%{} = bond, id_map) do
    bond = deep_atomize(bond)
    edge_layer_id = Map.get(id_map, bond.edge_layer_id)
    layer_id = Map.get(id_map, bond.layer_id)
    kind = parse_bond_kind(bond.kind)

    if edge_layer_id && layer_id && kind do
      bond
      |> Map.put(:edge_layer_id, edge_layer_id)
      |> Map.put(:layer_id, layer_id)
      |> Map.put(:kind, kind)
    end
  end

  defp remap_bond(_, _id_map), do: nil

  defp parse_bond_kind(:source), do: :source
  defp parse_bond_kind(:target), do: :target
  defp parse_bond_kind("source"), do: :source
  defp parse_bond_kind("target"), do: :target
  defp parse_bond_kind(_), do: nil

  defp root_layer_ids(layers, hierarchy) do
    layer_ids =
      layers
      |> Enum.map(&value(&1, :id))
      |> Enum.reject(&is_nil/1)
      |> MapSet.new()

    nested_ids =
      hierarchy
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

  defp nested_descendant(parenthood) do
    case value(parenthood, :depth) do
      depth when is_integer(depth) and depth > 0 -> [value(parenthood, :descendant_id)]
      _ -> []
    end
  end

  defp origin(layers) do
    case bounds(layers) do
      nil -> %{"x" => 0, "y" => 0}
      %{min_x: x, min_y: y} -> %{"x" => x, "y" => y}
    end
  end

  defp bounds(layers) do
    layers
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
    [%{x: number(value(text, :position_x)), y: number(value(text, :position_y))}]
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

  defp deep_atomize(value) when is_map(value) do
    value
    |> Enum.map(fn {key, nested_value} -> {atom_key(key), deep_atomize(nested_value)} end)
    |> Map.new()
  end

  defp deep_atomize(value) when is_list(value), do: Enum.map(value, &deep_atomize/1)
  defp deep_atomize(value), do: value

  defp atom_key(key) when is_atom(key), do: key

  defp atom_key(key) when is_binary(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> key
  end
end
