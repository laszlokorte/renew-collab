defmodule RenewCollab.Commands.ReorderLayersRelative do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood

  defstruct [:document_id, :layer_ids, :relative_direction, :target]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        relative_direction: relative_direction,
        target: target
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_ids: normalize_layer_ids([layer_id]),
      relative_direction: relative_direction,
      target: target
    }
  end

  def new(%{
        document_id: document_id,
        layer_ids: layer_ids,
        relative_direction: relative_direction,
        target: target
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_ids: normalize_layer_ids(layer_ids),
      relative_direction: relative_direction,
      target: target
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_ids: layer_ids,
        relative_direction: relative_direction,
        target: target
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :ordered_layer_ids,
      ordered_top_layer_ids_query(document_id, layer_ids, relative_direction)
    )
    |> Ecto.Multi.merge(fn %{ordered_layer_ids: ordered_layer_ids} ->
      ordered_layer_ids
      |> Enum.with_index()
      |> Enum.reduce(Ecto.Multi.new(), fn {layer_id, index}, multi ->
        ref_id = {__MODULE__, index, layer_id}
        result_key = RenewCollab.Queries.LayerHierarchyRelative.result_key(ref_id)

        relative_multi =
          RenewCollab.Queries.LayerHierarchyRelative.new(%{
            document_id: document_id,
            layer_id: layer_id,
            id_only: true,
            relative: relative_direction,
            ref_id: ref_id
          })
          |> RenewCollab.Queries.LayerHierarchyRelative.multi()
          |> Ecto.Multi.merge(fn changes ->
            case Map.get(changes, result_key) do
              nil ->
                Ecto.Multi.new()

              target_id ->
                RenewCollab.Commands.ReorderLayer.new(%{
                  document_id: document_id,
                  layer_id: layer_id,
                  target_layer_id: target_id,
                  target: target
                })
                |> RenewCollab.Commands.ReorderLayer.multi()
            end
          end)

        Ecto.Multi.append(multi, relative_multi)
      end)
    end)
  end

  defp ordered_top_layer_ids_query(document_id, layer_ids, relative_direction) do
    order =
      case relative_direction do
        {:sibling, :next} -> :desc
        {:sibling, :first} -> :desc
        _ -> :asc
      end

    from(l in Layer,
      left_join: selected_parent in LayerParenthood,
      on:
        selected_parent.document_id == ^document_id and selected_parent.descendant_id == l.id and
          selected_parent.depth > 0 and selected_parent.ancestor_id in ^layer_ids,
      where: l.document_id == ^document_id and l.id in ^layer_ids,
      where: is_nil(selected_parent.id),
      order_by: [{^order, l.z_index}],
      select: l.id
    )
  end

  defp normalize_layer_ids(layer_ids) do
    layer_ids
    |> List.wrap()
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end
end
