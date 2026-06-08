defmodule RenewCollab.Queries.LayerGraphRelation do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer

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

        :all ->
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
      end
    )
  end

  def result_key(nil), do: :result
  def result_key(ref_id), do: {ref_id, :result}
end
