defmodule RenewCollab.Commands.UpdateLayerEdgeAttributes do
  import Ecto.Query, warn: false

  alias RenewCollab.Element.Edge
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :attributes]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        attributes: attributes
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      attributes: attributes
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        attributes: attributes
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: b in assoc(l, :edge), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :position,
      fn %{edge: edge} ->
        Edge.attribute_changeset(edge, attributes)
      end
    )
  end
end
