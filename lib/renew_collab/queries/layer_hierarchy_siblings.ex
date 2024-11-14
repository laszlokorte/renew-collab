defmodule RenewCollab.Queries.LayerHierarchySiblings do
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
        left_join: p in assoc(l, :direct_parent_hood),
        left_join: s in assoc(p, :siblings),
        left_join: r in assoc(l, :layers_of_document),
        left_join: rp in assoc(r, :direct_parent_hood),
        where: r.id != l.id and l.document_id == ^document_id and l.id == ^layer_id,
        where: (is_nil(p.id) and is_nil(rp.id)) or s.descendant_id == r.id,
        order_by: [asc: r.z_index],
        select: r
      )
    )
  end
end
