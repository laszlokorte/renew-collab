defmodule RenewCollab.Queries.LayerHierarchyRelativeMultiple do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :rel, :ref_id]

  def new(
        %{
          document_id: document_id,
          layer_id: layer_id,
          rel: rel
        } = attrs
      ) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      rel: rel,
      ref_id: Map.get(attrs, :ref_id)
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        rel: rel,
        ref_id: ref_id
      }) do
    result_key = result_key(ref_id)

    Ecto.Multi.new()
    |> Ecto.Multi.all(
      result_key,
      case rel do
        :ancestors ->
          from(l in Layer,
            inner_join: p in LayerParenthood,
            on: p.ancestor_id == l.id and p.descendant_id == ^layer_id and p.depth > 0,
            where: l.document_id == ^document_id,
            select: l.id
          )

        :descendants ->
          from(l in Layer,
            inner_join: p in LayerParenthood,
            on: p.descendant_id == l.id and p.ancestor_id == ^layer_id and p.depth > 0,
            where: l.document_id == ^document_id,
            select: l.id
          )

        :root ->
          from(l in Layer,
            inner_join: p in LayerParenthood,
            on: p.ancestor_id == l.id and p.descendant_id == ^layer_id and p.depth > 0,
            left_join: c in LayerParenthood,
            on: c.descendant_id == l.id and c.depth > 0,
            where: l.document_id == ^document_id and is_nil(c.id),
            select: l.id
          )

        :leafs ->
          from(l in Layer,
            inner_join: p in LayerParenthood,
            on: p.descendant_id == l.id and p.ancestor_id == ^layer_id and p.depth > 0,
            left_join: c in LayerParenthood,
            on: c.ancestor_id == l.id and c.depth > 0,
            where: l.document_id == ^document_id and is_nil(c.id),
            select: l.id
          )

        {:siblings, pos} ->
          from(
            l in Layer,
            left_join: p in assoc(l, :direct_parent_hood),
            left_join: s in assoc(p, :siblings),
            left_join: r in assoc(l, :layers_of_document),
            left_join: rp in assoc(r, :direct_parent_hood),
            where: r.id != l.id and l.document_id == ^document_id and l.id == ^layer_id,
            where: (is_nil(p.id) and is_nil(rp.id)) or s.descendant_id == r.id,
            where:
              (^(pos == :before) and l.z_index > r.z_index) or
                (^(pos == :after) and l.z_index < r.z_index) or ^(pos == :all),
            select: r.id
          )

        :children ->
          from(l in Layer,
            left_join: p in assoc(l, :direct_parent_layer),
            where: p.document_id == ^document_id and p.id == ^layer_id,
            select: l.id
          )
      end
    )
  end

  def result_key(nil), do: :result
  def result_key(ref_id), do: {ref_id, :result}
end
