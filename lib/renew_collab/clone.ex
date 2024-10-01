defmodule RenewCollab.Clone do
  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.LayerStyle
  alias RenewCollab.Style.EdgeStyle
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Element.Edge
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Text
  alias RenewCollab.Element.Interface
  alias RenewCollab.Versioning

  def deep_clone_document(id) do
    Repo.transaction(fn ->
      doc =
        Repo.one(
          from(d in Document,
            where: d.id == ^id,
            left_join: l in assoc(d, :layers),
            left_join: b in assoc(l, :box),
            left_join: t in assoc(l, :text),
            left_join: e in assoc(l, :edge),
            left_join: w in assoc(e, :waypoints),
            left_join: ls in assoc(l, :style),
            left_join: ts in assoc(t, :style),
            left_join: es in assoc(e, :style),
            left_join: i in assoc(l, :interface),
            preload: [
              layers:
                {l,
                 [
                   box: b,
                   text: {t, [style: ts]},
                   edge: {e, [style: es, waypoints: w]},
                   style: ls,
                   interface: i
                 ]}
            ]
          )
        )

      new_layers_ids =
        doc.layers
        |> Enum.map(fn layer -> {layer.id, Ecto.UUID.generate()} end)
        |> Map.new()

      document_data =
        doc
        |> Map.from_struct()
        |> Map.delete(:id)
        |> Map.delete(:__meta__)
        |> Map.delete(:inserted_at)
        |> Map.delete(:updated_at)
        |> Map.update(:layers, [], fn layers ->
          layers
          |> Enum.map(fn %{id: old_id} = layer ->
            layer
            |> Map.from_struct()
            |> deep_strip()
            |> Map.put(:id, Map.get(new_layers_ids, old_id))
          end)
        end)

      new_parenthoods =
        from(p in LayerParenthood, where: p.document_id == ^id, select: p)
        |> Repo.all()
        |> Enum.map(fn %{depth: d, ancestor_id: anc, descendant_id: dec} ->
          {
            Map.get(new_layers_ids, anc),
            Map.get(new_layers_ids, dec),
            d
          }
        end)

      hyperlinks =
        from(h in Hyperlink,
          join: s in assoc(h, :source_layer),
          join: t in assoc(h, :target_layer),
          where: s.document_id == ^id and t.document_id == ^id,
          select: h
        )
        |> Repo.all()
        |> Enum.map(fn hyperlink ->
          Map.new()
          |> Map.put(:source_layer_id, Map.get(new_layers_ids, hyperlink.source_layer_id))
          |> Map.put(:target_layer_id, Map.get(new_layers_ids, hyperlink.target_layer_id))
        end)

      new_bonds =
        from(b in Bond,
          join: e in assoc(b, :element_edge),
          join: l in assoc(e, :layer),
          where: l.document_id == ^id,
          select: %{
            edge_layer_id: l.id,
            layer_id: b.layer_id,
            socket_id: b.socket_id,
            kind: b.kind
          }
        )
        |> Repo.all()
        |> Enum.map(fn bond ->
          bond
          |> Map.update(:edge_layer_id, nil, &Map.get(new_layers_ids, &1))
          |> Map.update(:layer_id, nil, &Map.get(new_layers_ids, &1))
        end)

      {document_data, new_parenthoods, hyperlinks, new_bonds}
    end)
  end

  def duplicate_document(id) do
    with {:ok, {doc_params, parenthoods, hyperlinks, bonds}} <- deep_clone_document(id) do
      RenewCollab.Renew.create_document(
        doc_params
        |> Map.update(:name, "Untitled", &"#{String.trim_trailing(&1, "(Copy)")} (Copy)"),
        parenthoods,
        hyperlinks,
        bonds
      )
    end
  end

  defp deep_strip(value) when is_struct(value) do
    value
    |> Map.from_struct()
    |> Enum.filter(&deep_strip_filter/1)
    |> Enum.map(fn {k, v} -> {k, deep_strip(v)} end)
    |> Map.new()
  end

  defp deep_strip(value) when is_map(value) do
    value
    |> Enum.filter(&deep_strip_filter/1)
    |> Enum.map(fn {k, v} -> {k, deep_strip(v)} end)
    |> Map.new()
  end

  defp deep_strip(value) when is_list(value) do
    value |> Enum.map(&deep_strip/1)
  end

  defp deep_strip(value) do
    value
  end

  defp deep_strip_filter({:__meta__, _}), do: false
  defp deep_strip_filter({:inserted_at, _}), do: false
  defp deep_strip_filter({:updated_at, _}), do: false
  defp deep_strip_filter({:socket_id, _}), do: true
  defp deep_strip_filter({:socket_schema_id, _}), do: true
  defp deep_strip_filter({:symbol_shape_id, _}), do: true
  defp deep_strip_filter({:source_tip_symbol_shape_id, _}), do: true
  defp deep_strip_filter({:target_tip_symbol_shape_id, _}), do: true
  defp deep_strip_filter({:id, _}), do: false
  defp deep_strip_filter({_k, %Ecto.Association.NotLoaded{}}), do: false

  defp deep_strip_filter({key, _}) when is_atom(key),
    do: not String.ends_with?(Atom.to_string(key), "_id")

  defp deep_strip_filter({key, _}) when is_binary(key), do: not String.ends_with?(key, "_id")
  defp deep_strip_filter({k, v}), do: true
end
