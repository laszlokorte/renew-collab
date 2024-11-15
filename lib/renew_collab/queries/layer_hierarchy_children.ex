defmodule RenewCollab.Queries.LayerHierarchyChildren do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :id_only]

  def new(%{document_id: document_id, layer_id: layer_id, id_only: id_only}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, id_only: id_only}
  end

  def new(%{document_id: document_id, layer_id: layer_id}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, id_only: false}
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, id_only: id_only}) do
    query =
      from(l in Layer,
        join: p in assoc(l, :direct_parent_layer),
        where: p.document_id == ^document_id and p.id == ^layer_id,
        order_by: [asc: l.z_index]
      )

    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      if(id_only,
        do:
          from(l in query,
            select: l.id
          ),
        else:
          from(l in query,
            select: l
          )
      )
    )
  end
end
