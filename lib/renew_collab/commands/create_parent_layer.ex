defmodule RenewCollab.Commands.CreateParentLayer do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood

  defstruct [:document_id, :attrs, :layer_ids]

  def new(%{
        document_id: document_id,
        attrs: attrs,
        layer_ids: layer_ids
      }) do
    %__MODULE__{
      document_id: document_id,
      attrs: attrs,
      layer_ids: normalize_layer_ids(layer_ids)
    }
  end

  def new(%{
        document_id: document_id,
        attrs: attrs,
        child_layer_id: child_layer_id
      }) do
    %__MODULE__{
      document_id: document_id,
      attrs: attrs,
      layer_ids: normalize_layer_ids([child_layer_id])
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        attrs: attrs,
        layer_ids: layer_ids
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(:top_layer_ids, top_layer_ids_query(document_id, layer_ids))
    |> Ecto.Multi.merge(fn
      %{top_layer_ids: [base_layer_id | _rest] = top_layer_ids} ->
        RenewCollab.Commands.CreateLayer.new(%{
          base_layer_id: base_layer_id,
          document_id: document_id,
          attrs: attrs
        })
        |> RenewCollab.Commands.CreateLayer.multi()
        |> Ecto.Multi.merge(fn %{layer: layer} ->
          RenewCollab.Commands.ReorderLayers.new(%{
            document_id: document_id,
            layer_ids: top_layer_ids,
            target_layer_id: layer.id,
            target: {:above, :inside}
          })
          |> RenewCollab.Commands.ReorderLayers.multi()
        end)

      %{top_layer_ids: []} ->
        Ecto.Multi.new()
    end)
  end

  defp top_layer_ids_query(document_id, layer_ids) do
    from(l in Layer,
      left_join: selected_parent in LayerParenthood,
      on:
        selected_parent.document_id == ^document_id and selected_parent.descendant_id == l.id and
          selected_parent.depth > 0 and selected_parent.ancestor_id in ^layer_ids,
      where: l.document_id == ^document_id and l.id in ^layer_ids,
      where: is_nil(selected_parent.id),
      order_by: [asc: l.z_index],
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
