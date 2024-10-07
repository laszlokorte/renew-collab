defmodule RenewCollab.Commands.UpdateLayerBoxShape do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  defstruct [:document_id, :layer_id, :shape_id, :attributes]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        shape_id: shape_id,
        attributes: attributes
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      shape_id: shape_id,
      attributes: attributes
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        shape_id: shape_id,
        attributes: attributes
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :box,
      from(l in Layer, join: b in assoc(l, :box), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{box: box} ->
        RenewCollab.Element.Box.changeset(box, %{
          symbol_shape_id: shape_id,
          symbol_shape_attributes: attributes
        })
      end
    )
  end
end
