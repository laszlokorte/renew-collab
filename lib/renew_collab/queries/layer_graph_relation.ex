defmodule RenewCollab.Queries.LayerGraphRelation do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Element.Edge

  defstruct [:document_id, :layer_id, :rel, :ref_id]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        rel: rel
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      rel: rel
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        ref_id: ref_id,
        rel: rel
      }) do
    result_key = result_key(ref_id)

    Ecto.Multi.new()
    |> Ecto.Multi.all(
      result_key,
      case rel do
        :source ->
          from(l in Layer,
            where: l.document_id == ^document_id,
            join: b in assoc(l, :attached_bonds),
            join: e in assoc(b, :element_edge),
            where: b.kind == :source and e.layer_id == ^layer_id,
            select: l.id
          )

        :target ->
          from(l in Layer,
            where: l.document_id == ^document_id,
            join: b in assoc(l, :attached_bonds),
            join: e in assoc(b, :element_edge),
            where: b.kind == :target and e.layer_id == ^layer_id,
            select: l.id
          )

        :nodes ->
          from(l in Layer,
            where: l.document_id == ^document_id,
            join: b in assoc(l, :attached_bonds),
            join: e in assoc(b, :element_edge),
            where: e.layer_id == ^layer_id,
            select: l.id
          )

        :incoming ->
          from(l in Layer,
            where: l.document_id == ^document_id,
            join: b in assoc(l, :attached_bonds),
            join: e in assoc(b, :element_edge),
            where: b.kind == :target and b.layer_id == ^layer_id,
            select: e.layer_id
          )

        :outgoing ->
          from(l in Layer,
            where: l.document_id == ^document_id,
            join: b in assoc(l, :attached_bonds),
            join: e in assoc(b, :element_edge),
            where: b.kind == :source and b.layer_id == ^layer_id,
            select: e.layer_id
          )

        :edges ->
          from(l in Layer,
            where: l.document_id == ^document_id,
            join: b in assoc(l, :attached_bonds),
            join: e in assoc(b, :element_edge),
            where: b.layer_id == ^layer_id,
            select: e.layer_id
          )

        :any ->
          union(
            from(l in Layer,
              where: l.document_id == ^document_id,
              join: b in assoc(l, :attached_bonds),
              join: e in assoc(b, :element_edge),
              where: e.layer_id == ^layer_id,
              select: l.id
            ),
            ^from(l in Layer,
              where: l.document_id == ^document_id,
              join: b in assoc(l, :attached_bonds),
              join: e in assoc(b, :element_edge),
              where: b.layer_id == ^layer_id,
              select: e.layer_id
            )
          )

        :all ->
          base =
            from l in Layer,
              where: l.document_id == ^document_id and l.id == ^layer_id,
              select: %{layer_id: l.id}

          edge_step =
            from c in "component",
              join: b in Bond,
              on: b.layer_id == c.layer_id,
              join: e in Edge,
              on: e.id == b.element_edge_id,
              select: %{layer_id: e.layer_id}

          node_step =
            from c in "component",
              join: e in Edge,
              on: e.layer_id == c.layer_id,
              join: b in Bond,
              on: b.element_edge_id == e.id,
              select: %{layer_id: b.layer_id}

          cte =
            base
            |> union(^edge_step)
            |> union(^node_step)

          Layer
          |> recursive_ctes(true)
          |> with_cte("component", as: ^cte)
          |> join(:inner, [l], c in "component", on: c.layer_id == l.id)
          |> select([l], l.id)
      end
    )
  end

  def result_key(nil), do: :result
  def result_key(ref_id), do: {ref_id, :result}
end
