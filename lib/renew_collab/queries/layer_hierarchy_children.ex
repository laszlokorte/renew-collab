defmodule RenewCollab.Queries.LayerHierarchyChildren do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id]

  def new(%{document_id: document_id, layer_id: layer_id}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id}
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(l in Layer,
        join: p in assoc(l, :direct_parent_layer),
        where: p.document_id == ^document_id and p.id == ^layer_id,
        order_by: [asc: l.z_index],
        select: l
      )
    )
  end
end
