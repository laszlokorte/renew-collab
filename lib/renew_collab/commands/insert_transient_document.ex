defmodule RenewCollab.Commands.InsertTransientDocument do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Element.Edge
  alias RenewCollab.Import.Converted

  defstruct [:converted_document, :target_document_id, :position, :target]

  def new(%{
        target_document_id: target_document_id,
        converted_document: converted_document,
        position: {x, y}
      }) do
    %__MODULE__{
      target_document_id: target_document_id,
      converted_document: converted_document,
      position: {x, y}
    }
  end

  def new(%{
        target_document_id: target_document_id,
        converted_document: converted_document
      }) do
    %__MODULE__{
      target_document_id: target_document_id,
      converted_document: converted_document,
      position: {0, 0}
    }
  end

  def tags(%__MODULE__{target_document_id: target_document_id}),
    do: [{:document_content, target_document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        target_document_id: target_document_id,
        converted_document: converted_document,
        position: {_dx, _dy}
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:stripped_document, converted_document)
    |> Ecto.Multi.put(:document_id, target_document_id)
    |> Ecto.Multi.run(:now, fn _, %{} ->
      {:ok, DateTime.utc_now() |> DateTime.truncate(:second)}
    end)
    |> Ecto.Multi.merge(fn %{
                             now: now,
                             document_id: document_id,
                             stripped_document: %Converted{} = converted_document
                           } ->
      insert_into_document_multi(
        document_id,
        now,
        converted_document
      )
    end)
  end

  defp insert_into_document_multi(
         document_id,
         now,
         %Converted{
           layers: layers,
           hierarchy: hierarchy,
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
        hierarchy,
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

  def parse_hierarchy_position("above", "inside"), do: {:above, :inside}
  def parse_hierarchy_position("above", "outside"), do: {:above, :outside}
  def parse_hierarchy_position("below", "outside"), do: {:below, :outside}
  def parse_hierarchy_position("below", "inside"), do: {:below, :inside}
end
