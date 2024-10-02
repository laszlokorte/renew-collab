defmodule RenewCollab.Commands.InsertDocument do
  alias __MODULE__

  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood

  defstruct [:source_document_id, :target_document_id]

  def new(%{target_document_id: target_document_id, source_document_id: source_document_id}) do
    %__MODULE__{target_document_id: target_document_id, source_document_id: source_document_id}
  end

  def multi(%__MODULE__{
        source_document_id: source_document_id,
        target_document_id: target_document_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:source_document, fn _, %{} ->
      RenewCollab.Clone.deep_clone_document(source_document_id)
    end)
    |> Ecto.Multi.merge(fn %{source_document: {%{layers: layers}, parenthoods, hyperlinks, bonds}} ->
      Ecto.Multi.new()
      |> Ecto.Multi.put(:document_id, target_document_id)
      |> Ecto.Multi.append(
        insert_into_document_multi(
          layers,
          parenthoods,
          hyperlinks,
          bonds
        )
      )
    end)
  end

  def insert_into_document_multi(layers \\ [], parenthoods \\ [], hyperlinks \\ [], bonds \\ []) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    layers
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {layer, i}, mul ->
      mul
      |> Ecto.Multi.insert(
        "insert_layer_#{i}",
        fn %{document_id: document_id} ->
          %Layer{document_id: document_id} |> Layer.changeset(layer)
        end
      )
    end)
    |> Ecto.Multi.insert_all(
      :insert_parenthoods,
      LayerParenthood,
      fn %{document_id: document_id} ->
        Enum.map(
          parenthoods,
          fn {ancestor_id, descendant_id, depth} ->
            %{
              depth: depth,
              ancestor_id: ancestor_id,
              descendant_id: descendant_id,
              document_id: document_id
            }
          end
        )
      end,
      on_conflict: {:replace, [:depth, :ancestor_id, :descendant_id]}
    )
    |> Ecto.Multi.insert_all(
      :insert_hyperlinks,
      Hyperlink,
      fn _ ->
        hyperlinks
        |> Enum.map(fn %{
                         source_layer_id: source_layer_id,
                         target_layer_id: target_layer_id
                       } ->
          %{
            source_layer_id: source_layer_id,
            target_layer_id: target_layer_id,
            inserted_at: now,
            updated_at: now
          }
        end)
      end
    )
    |> Ecto.Multi.all(
      :layer_edge_ids,
      fn %{document_id: document_id} ->
        from(e in Edge,
          join: l in assoc(e, :layer),
          where: l.document_id == ^document_id,
          select: {l.id, e.id}
        )
      end
    )
    |> then(fn multi ->
      bonds
      |> Enum.chunk_every(500)
      |> Enum.with_index()
      |> Enum.reduce(multi, fn {bond_chunk, chunk_index}, multi ->
        Ecto.Multi.insert_all(
          multi,
          :"insert_bonds_#{chunk_index}",
          Bond,
          fn %{layer_edge_ids: layer_edge_ids} ->
            layer_edge_map = Map.new(layer_edge_ids)

            bond_chunk
            |> Enum.map(fn
              %{
                edge_layer_id: edge_layer_id,
                layer_id: layer_id,
                socket_id: socket_id,
                kind: kind
              } ->
                %{
                  element_edge_id: Map.get(layer_edge_map, edge_layer_id),
                  layer_id: layer_id,
                  socket_id: socket_id,
                  kind: kind,
                  inserted_at: now,
                  updated_at: now
                }
            end)
          end
        )
      end)
    end)
  end
end
