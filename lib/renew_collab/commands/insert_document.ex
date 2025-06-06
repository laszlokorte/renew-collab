defmodule RenewCollab.Commands.InsertDocument do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.TransientDocument
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Element.Edge

  defstruct [:source_document_id, :target_document_id, :position]

  def new(%{
        target_document_id: target_document_id,
        source_document_id: source_document_id,
        position: {x, y}
      }) do
    %__MODULE__{
      target_document_id: target_document_id,
      source_document_id: source_document_id,
      position: {x, y}
    }
  end

  def new(%{
        target_document_id: target_document_id,
        source_document_id: source_document_id
      }) do
    %__MODULE__{
      target_document_id: target_document_id,
      source_document_id: source_document_id,
      position: {0, 0}
    }
  end

  def tags(%__MODULE__{target_document_id: target_document_id}),
    do: [{:document_content, target_document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        source_document_id: source_document_id,
        target_document_id: target_document_id,
        position: {dx, dy}
      }) do
    RenewCollab.Queries.StrippedDocument.new(%{document_id: source_document_id})
    |> RenewCollab.Queries.StrippedDocument.multi()
    |> Ecto.Multi.run(:stripped_document, fn _, %{result: result} ->
      {:ok, result}
    end)
    |> Ecto.Multi.put(:document_id, target_document_id)
    |> Ecto.Multi.run(:now, fn _, %{} ->
      {:ok, DateTime.utc_now() |> DateTime.truncate(:second)}
    end)
    |> Ecto.Multi.merge(fn %{
                             now: now,
                             document_id: document_id,
                             stripped_document: %TransientDocument{} = stripped_document
                           } ->
      insert_into_document_multi(
        document_id,
        now,
        stripped_document |> TransientDocument.shift_positions(dx, dy)
      )
    end)
  end

  defp insert_into_document_multi(
         document_id,
         now,
         %TransientDocument{
           content: %{layers: layers},
           parenthoods: parenthoods,
           hyperlinks: hyperlinks,
           bonds: bonds
         }
       ) do
    layers
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {layer, i}, mul ->
      mul
      |> Ecto.Multi.insert(
        {:insert_layer, i},
        %Layer{document_id: document_id} |> Layer.changeset(layer)
      )
    end)
    |> RenewCollab.Compatibility.Multi.insert_all(
      :insert_parenthoods,
      LayerParenthood,
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
      ),
      on_conflict: {:replace, [:depth, :ancestor_id, :descendant_id]},
      conflict_target: [:descendant_id, :ancestor_id]
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
      from(e in Edge,
        join: l in assoc(e, :layer),
        where: l.document_id == ^document_id,
        select: {l.id, e.id}
      )
    )
    |> then(fn multi ->
      bonds
      |> Enum.chunk_every(500)
      |> Enum.with_index()
      |> Enum.reduce(multi, fn {bond_chunk, chunk_index}, multi ->
        Ecto.Multi.insert_all(
          multi,
          {:insert_bonds, chunk_index},
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
