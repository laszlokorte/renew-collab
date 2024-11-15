defmodule RenewCollab.Queries.LayerHierarchyChildren do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :id_only]

  def new(%{document_id: document_id, layer_id: layer_id, id_only: id_only}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, id_only: id_only}
  end

  def new(%{document_id: document_id, layer_id: layer_id}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, id_only: true}
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, id_only: id_only}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(l in Layer,
        join: p in assoc(l, :direct_parent_layer),
        where: p.document_id == ^document_id and p.id == ^layer_id,
        order_by: [asc: l.z_index],
        select: l
      )
      |> then(&if(id_only, do: select(exclude(&1, :select), [l, p], l.id), else: &1))
    )
  end
end
