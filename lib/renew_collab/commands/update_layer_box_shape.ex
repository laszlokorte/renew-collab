defmodule RenewCollab.Commands.UpdateLayerBoxShape do
  import Ecto.Query, warn: false

  alias RenewCollab.Element.Box

  defstruct [:document_id, :layer_ids, :shape_id, :attributes]

  def new(
        %{
          document_id: document_id,
          shape_id: shape_id,
          attributes: attributes
        } = attrs
      ) do
    layer_ids = normalize_layer_ids(attrs)

    %__MODULE__{
      document_id: document_id,
      layer_ids: layer_ids,
      shape_id: shape_id,
      attributes: attributes
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_ids: layer_ids,
        shape_id: shape_id,
        attributes: attributes
      }) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.update_all(
      :update_boxes,
      from(b in Box,
        join: l in assoc(b, :layer),
        where: l.document_id == ^document_id and l.id in ^layer_ids,
        update: [
          set: [
            symbol_shape_id: ^shape_id,
            symbol_shape_attributes: ^attributes,
            updated_at: ^now
          ]
        ]
      ),
      []
    )
  end

  defp normalize_layer_ids(%{layer_ids: layer_ids}) when is_list(layer_ids) do
    layer_ids
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  defp normalize_layer_ids(_), do: []
end
