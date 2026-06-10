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
    layer = deep_atomize(layer)
    id = value(layer, :id)

    layer
    |> Map.put(:direct_parent_hood, Map.get(parent_by_child, id))
    |> Map.put(:outgoing_link, Map.get(outgoing_link_by_source, id))
    |> Map.update(:edge, nil, &prepare_export_edge(&1, Map.get(bonds_by_edge, id, [])))
  end

  defp prepare_export_edge(nil, _bonds), do: nil

  defp prepare_export_edge(edge, bonds) do
    edge = deep_atomize(edge)

    edge
    |> Map.put(:source_bond, Enum.find(bonds, &(parse_bond_kind(value(&1, :kind)) == :source)))
    |> Map.put(:target_bond, Enum.find(bonds, &(parse_bond_kind(value(&1, :kind)) == :target)))
  end

  defp parent_by_child(parenthoods) do
    parenthoods
    |> Enum.flat_map(fn
      {ancestor_id, descendant_id, 1} -> [{descendant_id, %{ancestor_id: ancestor_id}}]
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
          source_layer_id -> [{source_layer_id, deep_atomize(hyperlink)}]
        end

      _ ->
        []
    end)
    |> Map.new()
  end

  defp bonds_by_edge(bonds) do
    bonds
    |> Enum.map(&deep_atomize/1)
    |> Enum.group_by(&value(&1, :edge_layer_id))
  end

  defp value(map, key, default \\ nil)

  defp value(%{} = map, key, default) when is_atom(key) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end

  defp value(%{} = map, key, default), do: Map.get(map, key, default)
  defp value(_, _, default), do: default

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
