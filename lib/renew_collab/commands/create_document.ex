defmodule RenewCollab.Commands.CreateDocument do
  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Element.Edge

  defstruct [:doc]

  def new(%{doc: %RenewCollab.Document.TransientDocument{} = doc}) do
    %__MODULE__{
      doc: doc
    }
  end

  def tags(%__MODULE__{}), do: [:document_collection]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(
        %__MODULE__{
          doc: %RenewCollab.Document.TransientDocument{
            content: content,
            parenthoods: parenthoods,
            hyperlinks: hyperlinks,
            bonds: bonds
          }
        },
        id \\ nil
      ) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :insert_document,
      %Document{id: id}
      |> Document.changeset(content)
    )
    |> RenewCollab.Compatibility.Multi.insert_all(
      :insert_parenthoods,
      LayerParenthood,
      fn %{insert_document: new_document} ->
        Enum.map(
          parenthoods,
          fn {ancestor_id, descendant_id, depth} ->
            %{
              depth: depth,
              ancestor_id: ancestor_id,
              descendant_id: descendant_id,
              document_id: new_document.id
            }
          end
        )
      end,
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
      fn %{insert_document: new_document} ->
        from(e in Edge,
          join: l in assoc(e, :layer),
          where: l.document_id == ^new_document.id,
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
    |> Ecto.Multi.run(:document_id, fn _, %{insert_document: inserted_document} ->
      {:ok, inserted_document.id}
    end)
  end
end
