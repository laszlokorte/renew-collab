defmodule RenewCollab.Document.LayerClipboard do
  alias RenewCollab.Document.Document
  alias RenewCollab.Document.TransientDocument

  @default_document_kind "de.renew.gui.CPNDrawing"

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
      "origin" => TransientDocument.layers_origin(layers)
    }
  end

  def to_rnw(%TransientDocument{} = clipboard_document) do
    clipboard_document
    |> export_document()
    |> RenewCollab.Export.DocumentExport.export()
  rescue
    _ -> :error
  end

  def from_rnw(file_name, content) do
    with {:ok, imported} <- RenewCollab.Import.DocumentImport.import(file_name, content) do
      {:ok,
       encode(%TransientDocument{
         content: %{
           name: imported.name,
           kind: imported.kind,
           layers: imported.layers
         },
         parenthoods: imported.hierarchy,
         hyperlinks: imported.hyperlinks,
         bonds: imported.bonds,
         thumbnail: imported.thumbnail
       })}
    end
  rescue
    _ -> :error
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
        |> normalize_layer()
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
      }, TransientDocument.layers_origin(layers), root_layer_ids}}
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
    hyperlink = normalize_hyperlink(hyperlink)
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
    bond = normalize_bond(bond)
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

  defp export_document(%TransientDocument{
         content: content,
         parenthoods: parenthoods,
         hyperlinks: hyperlinks,
         bonds: bonds
       }) do
    parent_by_child = parent_by_child(parenthoods)
    outgoing_link_by_source = outgoing_link_by_source(hyperlinks)
    bonds_by_edge = bonds_by_edge(bonds)

    %Document{
      name: value(content, :name, "Clipboard"),
      kind: value(content, :kind, @default_document_kind),
      layers:
        content
        |> value(:layers, [])
        |> Enum.map(
          &prepare_export_layer(
            &1,
            parent_by_child,
            outgoing_link_by_source,
            bonds_by_edge
          )
        )
    }
  end

  defp prepare_export_layer(layer, parent_by_child, outgoing_link_by_source, bonds_by_edge) do
    layer = normalize_layer(layer)
    id = value(layer, :id)

    layer
    |> Map.put(:direct_parent_hood, Map.get(parent_by_child, id))
    |> Map.put(:outgoing_link, Map.get(outgoing_link_by_source, id))
    |> Map.update(:edge, nil, &prepare_export_edge(&1, Map.get(bonds_by_edge, id, [])))
  end

  defp prepare_export_edge(nil, _bonds), do: nil

  defp prepare_export_edge(edge, bonds) do
    edge = normalize_edge(edge)

    edge
    |> Map.put(:source_bond, Enum.find(bonds, &(parse_bond_kind(value(&1, :kind)) == :source)))
    |> Map.put(:target_bond, Enum.find(bonds, &(parse_bond_kind(value(&1, :kind)) == :target)))
  end

  defp parent_by_child(parenthoods) do
    parenthoods
    |> Enum.flat_map(fn
      {ancestor_id, descendant_id, 1} ->
        [{descendant_id, %{ancestor_id: ancestor_id}}]

      %{} = parenthood ->
        case {value(parenthood, :ancestor_id), value(parenthood, :descendant_id),
              value(parenthood, :depth)} do
          {ancestor_id, descendant_id, 1} -> [{descendant_id, %{ancestor_id: ancestor_id}}]
          _ -> []
        end

      _ ->
        []
    end)
    |> Map.new()
  end

  defp outgoing_link_by_source(hyperlinks) do
    hyperlinks
    |> Enum.flat_map(fn
      %{} = hyperlink ->
        case value(hyperlink, :source_layer_id) do
          nil -> []
          source_layer_id -> [{source_layer_id, normalize_hyperlink(hyperlink)}]
        end

      _ ->
        []
    end)
    |> Map.new()
  end

  defp bonds_by_edge(bonds) do
    bonds
    |> Enum.map(&normalize_bond/1)
    |> Enum.group_by(&value(&1, :edge_layer_id))
  end

  defp value(map, key, default \\ nil)

  defp value(%{} = map, key, default) when is_atom(key) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end

  defp value(%{} = map, key, default), do: Map.get(map, key, default)
  defp value(_, _, default), do: default

  defp normalize_layer(%{} = layer) do
    %{}
    |> put_present(:id, value(layer, :id))
    |> put_present(:z_index, value(layer, :z_index))
    |> put_present(:semantic_tag, value(layer, :semantic_tag))
    |> put_present(:hidden, value(layer, :hidden))
    |> put_present(:box, normalize_optional(layer, :box, &normalize_box/1))
    |> put_present(:text, normalize_optional(layer, :text, &normalize_text/1))
    |> put_present(:edge, normalize_optional(layer, :edge, &normalize_edge/1))
    |> put_present(:style, normalize_optional(layer, :style, &normalize_layer_style/1))
    |> put_present(:interface, normalize_optional(layer, :interface, &normalize_interface/1))
    |> put_present(
      :direct_parent_hood,
      normalize_optional(layer, :direct_parent_hood, &normalize_parent_hood/1)
    )
    |> put_present(
      :outgoing_link,
      normalize_optional(layer, :outgoing_link, &normalize_hyperlink/1)
    )
  end

  defp normalize_layer(_), do: %{}

  defp normalize_box(%{} = box) do
    %{}
    |> put_present(:position_x, value(box, :position_x))
    |> put_present(:position_y, value(box, :position_y))
    |> put_present(:width, value(box, :width))
    |> put_present(:height, value(box, :height))
    |> put_present(:symbol_shape_id, value(box, :symbol_shape_id))
    |> put_present(:symbol_shape_attributes, value(box, :symbol_shape_attributes))
  end

  defp normalize_box(_), do: %{}

  defp normalize_text(%{} = text) do
    %{}
    |> put_present(:position_x, value(text, :position_x))
    |> put_present(:position_y, value(text, :position_y))
    |> put_present(:body, value(text, :body))
    |> put_present(:renew_type, value(text, :renew_type))
    |> put_present(:style, normalize_optional(text, :style, &normalize_text_style/1))
    |> put_present(:size_hint, normalize_optional(text, :size_hint, &normalize_size_hint/1))
  end

  defp normalize_text(_), do: %{}

  defp normalize_edge(%{} = edge) do
    %{}
    |> put_present(:source_x, value(edge, :source_x))
    |> put_present(:source_y, value(edge, :source_y))
    |> put_present(:target_x, value(edge, :target_x))
    |> put_present(:target_y, value(edge, :target_y))
    |> put_present(:cyclic, value(edge, :cyclic))
    |> put_present(:style, normalize_optional(edge, :style, &normalize_edge_style/1))
    |> put_present(:waypoints, normalize_list(edge, :waypoints, &normalize_waypoint/1))
    |> put_present(:source_bond, normalize_optional(edge, :source_bond, &normalize_bond/1))
    |> put_present(:target_bond, normalize_optional(edge, :target_bond, &normalize_bond/1))
  end

  defp normalize_edge(_), do: %{}

  defp normalize_layer_style(%{} = style) do
    %{}
    |> put_present(:opacity, value(style, :opacity))
    |> put_present(:background_color, value(style, :background_color))
    |> put_present(:background_url, value(style, :background_url))
    |> put_present(:target_location, value(style, :target_location))
    |> put_present(:border_color, value(style, :border_color))
    |> put_present(:border_width, value(style, :border_width))
    |> put_present(:border_dash_array, value(style, :border_dash_array))
  end

  defp normalize_layer_style(_), do: %{}

  defp normalize_text_style(%{} = style) do
    %{}
    |> put_present(:alignment, value(style, :alignment))
    |> put_present(:font_size, value(style, :font_size))
    |> put_present(:font_family, value(style, :font_family))
    |> put_present(:bold, value(style, :bold))
    |> put_present(:italic, value(style, :italic))
    |> put_present(:underline, value(style, :underline))
    |> put_present(:rich, value(style, :rich))
    |> put_present(:text_color, value(style, :text_color))
    |> put_present(:blank_lines, value(style, :blank_lines))
  end

  defp normalize_text_style(_), do: %{}

  defp normalize_edge_style(%{} = style) do
    %{}
    |> put_present(:stroke_width, value(style, :stroke_width))
    |> put_present(:stroke_color, value(style, :stroke_color))
    |> put_present(:stroke_join, value(style, :stroke_join))
    |> put_present(:stroke_cap, value(style, :stroke_cap))
    |> put_present(:stroke_dash_array, value(style, :stroke_dash_array))
    |> put_present(:smoothness, value(style, :smoothness))
    |> put_present(:source_tip_symbol_shape_id, value(style, :source_tip_symbol_shape_id))
    |> put_present(:target_tip_symbol_shape_id, value(style, :target_tip_symbol_shape_id))
    |> put_present(:source_tip_size, value(style, :source_tip_size))
    |> put_present(:target_tip_size, value(style, :target_tip_size))
  end

  defp normalize_edge_style(_), do: %{}

  defp normalize_size_hint(%{} = size_hint) do
    %{}
    |> put_present(:position_x, value(size_hint, :position_x))
    |> put_present(:position_y, value(size_hint, :position_y))
    |> put_present(:width, value(size_hint, :width))
    |> put_present(:height, value(size_hint, :height))
  end

  defp normalize_size_hint(_), do: %{}

  defp normalize_waypoint(%{} = waypoint) do
    %{}
    |> put_present(:position_x, value(waypoint, :position_x))
    |> put_present(:position_y, value(waypoint, :position_y))
    |> put_present(:sort, value(waypoint, :sort))
  end

  defp normalize_waypoint(_), do: %{}

  defp normalize_interface(%{} = interface) do
    %{}
    |> put_present(:socket_schema_id, value(interface, :socket_schema_id))
    |> put_present(:layer_id, value(interface, :layer_id))
  end

  defp normalize_interface(_), do: %{}

  defp normalize_parent_hood(%{} = parenthood) do
    %{}
    |> put_present(:ancestor_id, value(parenthood, :ancestor_id))
    |> put_present(:descendant_id, value(parenthood, :descendant_id))
    |> put_present(:depth, value(parenthood, :depth))
  end

  defp normalize_parent_hood(_), do: %{}

  defp normalize_hyperlink(%{} = hyperlink) do
    %{}
    |> put_present(:source_layer_id, value(hyperlink, :source_layer_id))
    |> put_present(:target_layer_id, value(hyperlink, :target_layer_id))
    |> put_present(:locator_offset_x, value(hyperlink, :locator_offset_x))
    |> put_present(:locator_offset_y, value(hyperlink, :locator_offset_y))
  end

  defp normalize_hyperlink(_), do: %{}

  defp normalize_bond(%{} = bond) do
    %{}
    |> put_present(:edge_layer_id, value(bond, :edge_layer_id))
    |> put_present(:layer_id, value(bond, :layer_id))
    |> put_present(:socket_id, value(bond, :socket_id))
    |> put_present(:kind, value(bond, :kind))
  end

  defp normalize_bond(_), do: %{}

  defp normalize_optional(map, key, normalizer) do
    case value(map, key) do
      %{} = nested -> normalizer.(nested)
      _ -> nil
    end
  end

  defp normalize_list(map, key, normalizer) do
    map
    |> value(key, [])
    |> List.wrap()
    |> Enum.filter(&is_map/1)
    |> Enum.map(normalizer)
  end

  defp put_present(map, _key, nil), do: map
  defp put_present(map, _key, []), do: map
  defp put_present(map, key, value), do: Map.put(map, key, value)
end
