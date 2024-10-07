defmodule RenewCollab.Commands.UpdateLayerSemanticTag do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :new_tag]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        new_tag: new_tag
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      new_tag: new_tag
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        new_tag: new_tag
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :layer,
      from(l in Layer, where: l.id == ^layer_id, select: l)
    )
    |> Ecto.Multi.update(
      :update,
      fn %{layer: layer} ->
        Ecto.Changeset.change(layer, semantic_tag: new_tag)
      end
    )
  end
end
