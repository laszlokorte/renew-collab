defmodule RenewCollab.Commands.UpdateLayerEdgeAttributes do
  import Ecto.Query, warn: false

  alias RenewCollab.Element.Edge

  defstruct [:document_id, :layer_ids, :attributes]

  def new(
        %{
          document_id: document_id,
          attributes: attributes
        } = attrs
      ) do
    layer_ids = normalize_layer_ids(attrs)

    %__MODULE__{
      document_id: document_id,
      layer_ids: layer_ids,
      attributes: attributes
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_ids: layer_ids,
        attributes: attributes
      }) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    cyclic = Map.get(attributes, "cyclic", Map.get(attributes, :cyclic))

    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> then(fn multi ->
      if is_boolean(cyclic) do
        Ecto.Multi.update_all(
          multi,
          :update_edges,
          from(e in Edge,
            join: l in assoc(e, :layer),
            where: l.document_id == ^document_id and l.id in ^layer_ids,
            update: [set: [cyclic: ^cyclic, updated_at: ^now]]
          ),
          []
        )
      else
        multi
      end
    end)
  end

  defp normalize_layer_ids(%{layer_ids: layer_ids}) when is_list(layer_ids) do
    layer_ids
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  defp normalize_layer_ids(_), do: []
end
