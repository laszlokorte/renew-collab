defmodule RenewCollab.Commands.ReorderLayers do
  defstruct [:document_id, :layer_ids, :target_layer_id, :target]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        target_layer_id: target_layer_id,
        target: target
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_ids: normalize_layer_ids([layer_id]),
      target_layer_id: target_layer_id,
      target: target
    }
  end

  def new(%{
        document_id: document_id,
        layer_ids: layer_ids,
        target_layer_id: target_layer_id,
        target: target
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_ids: normalize_layer_ids(layer_ids),
      target_layer_id: target_layer_id,
      target: target
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_ids: layer_ids,
        target_layer_id: target_layer_id,
        target: target
      }) do
    Enum.reduce(layer_ids, Ecto.Multi.new(), fn layer_id, multi ->
      command =
        RenewCollab.Commands.ReorderLayer.new(%{
          document_id: document_id,
          layer_id: layer_id,
          target_layer_id: target_layer_id,
          target: target
        })

      Ecto.Multi.append(multi, RenewCollab.Commands.ReorderLayer.multi(command))
    end)
  end

  defp normalize_layer_ids(layer_ids) do
    layer_ids
    |> List.wrap()
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end
end
