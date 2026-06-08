defmodule RenewCollab.Queries.LayerHierarchyConnectedComponent do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :ref_id]

  def new(
        %{
          document_id: document_id,
          layer_id: layer_id
        } = attrs
      ) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      ref_id: Map.get(attrs, :ref_id)
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        ref_id: ref_id
      }) do
    result_key = result_key(ref_id)

    Ecto.Multi.new()
    |> Ecto.Multi.all(
      result_key,
      from(l in Layer,
        where: l.document_id == ^document_id,
        inner_join: c in LayerParenthood,
        on: c.ancestor_id == ^layer_id and c.descendant_id == l.id,
        select: l.id
      )
    )
  end

  def result_key(nil), do: :result
  def result_key(ref_id), do: {ref_id, :result}
end
