defmodule RenewCollab.Commands.CreateParentLayer do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Element.Edge

  defstruct [:document_id, :attrs, :child_layer_id]

  def new(%{
        document_id: document_id,
        attrs: attrs,
        child_layer_id: child_layer_id
      }) do
    %__MODULE__{
      document_id: document_id,
      attrs: attrs,
      child_layer_id: child_layer_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        attrs: attrs,
        child_layer_id: child_layer_id
      }) do
    RenewCollab.Commands.CreateLayer.new(%{
      base_layer_id: child_layer_id,
      document_id: document_id,
      attrs: attrs
    })
    |> RenewCollab.Commands.CreateLayer.multi()
    |> Ecto.Multi.merge(fn %{layer: layer} ->
      RenewCollab.Commands.ReorderLayer.new(%{
        document_id: document_id,
        layer_id: child_layer_id,
        target_layer_id: layer.id,
        target: {:above, :inside}
      })
      |> RenewCollab.Commands.ReorderLayer.multi()
    end)
  end
end
