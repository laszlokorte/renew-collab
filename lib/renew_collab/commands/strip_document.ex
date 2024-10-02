defmodule RenewCollab.Commands.StripDocument do
  import Ecto.Query, warn: false

  alias RenewCollab.Document.Document
  alias RenewCollab.Document.TransientDocument
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Bond

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :original_document,
      from(d in Document,
        where: d.id == ^document_id,
        left_join: l in assoc(d, :layers),
        left_join: b in assoc(l, :box),
        left_join: t in assoc(l, :text),
        left_join: e in assoc(l, :edge),
        left_join: w in assoc(e, :waypoints),
        left_join: ls in assoc(l, :style),
        left_join: ts in assoc(t, :style),
        left_join: es in assoc(e, :style),
        left_join: i in assoc(l, :interface),
        order_by: [asc: l.z_index, asc: w.sort],
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
    |> Ecto.Multi.all(
      :original_parenthoods,
      fn %{original_document: %{id: doc_id}} ->
        from(p in LayerParenthood, where: p.document_id == ^doc_id, select: p)
      end
    )
    |> Ecto.Multi.all(:original_hyperlinks, fn %{original_document: %{id: doc_id}} ->
      from(h in Hyperlink,
        join: s in assoc(h, :source_layer),
        join: t in assoc(h, :target_layer),
        where: s.document_id == ^doc_id and t.document_id == ^doc_id,
        select: h
      )
    end)
    |> Ecto.Multi.all(
      :original_bonds,
      fn %{original_document: %{id: doc_id}} ->
        from(b in Bond,
          join: e in assoc(b, :element_edge),
          join: l in assoc(e, :layer),
          where: l.document_id == ^doc_id,
          select: %{
            edge_layer_id: l.id,
            layer_id: b.layer_id,
            socket_id: b.socket_id,
            kind: b.kind
          }
        )
      end
    )
    |> Ecto.Multi.run(:new_layer_ids, fn _, %{original_document: %{layers: layers}} ->
      {:ok,
       layers
       |> Enum.map(fn layer -> {layer.id, Ecto.UUID.generate()} end)
       |> Map.new()}
    end)
    |> Ecto.Multi.run(:new_document_content, fn _,
                                                %{
                                                  new_layer_ids: new_layer_ids,
                                                  original_document: original_document
                                                } ->
      {:ok,
       original_document
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
           |> Map.put(:id, Map.get(new_layer_ids, old_id))
         end)
       end)}
    end)
    |> Ecto.Multi.run(:new_parenthoods, fn _,
                                           %{
                                             original_parenthoods: original_parenthoods,
                                             new_layer_ids: new_layer_ids
                                           } ->
      {:ok,
       original_parenthoods
       |> Enum.map(fn %{depth: d, ancestor_id: anc, descendant_id: dec} ->
         {
           Map.get(new_layer_ids, anc),
           Map.get(new_layer_ids, dec),
           d
         }
       end)}
    end)
    |> Ecto.Multi.run(:new_hyperlinks, fn _,
                                          %{
                                            original_hyperlinks: original_hyperlinks,
                                            new_layer_ids: new_layer_ids
                                          } ->
      {:ok,
       original_hyperlinks
       |> Enum.map(fn hyperlink ->
         Map.new()
         |> Map.put(:source_layer_id, Map.get(new_layer_ids, hyperlink.source_layer_id))
         |> Map.put(:target_layer_id, Map.get(new_layer_ids, hyperlink.target_layer_id))
       end)}
    end)
    |> Ecto.Multi.run(:new_bonds, fn _,
                                     %{
                                       original_bonds: original_bonds,
                                       new_layer_ids: new_layer_ids
                                     } ->
      {:ok,
       original_bonds
       |> Enum.map(fn bond ->
         bond
         |> Map.update(:edge_layer_id, nil, &Map.get(new_layer_ids, &1))
         |> Map.update(:layer_id, nil, &Map.get(new_layer_ids, &1))
       end)}
    end)
    |> Ecto.Multi.run(:stripped_document, fn _,
                                             %{
                                               new_document_content: content,
                                               new_parenthoods: parenthoods,
                                               new_hyperlinks: hyperlinks,
                                               new_bonds: bonds
                                             } ->
      {:ok,
       %TransientDocument{
         content: content,
         parenthoods: parenthoods,
         hyperlinks: hyperlinks,
         bonds: bonds
       }}
    end)
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
  defp deep_strip_filter({_, _}), do: true
end
