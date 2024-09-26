defmodule RenewCollab.Hierarchy do
  import Ecto.Query, only: [from: 2, union: 2]

  alias RenewCollab.Hierarchy.LayerParenthood

  def repair_parenthood(doc_id) do
    RenewCollab.Repo.transaction(fn _ ->
      ids_to_delete = Enum.map(find_invalids(doc_id), & &1.id)
      RenewCollab.Repo.delete_all(from p in LayerParenthood, where: p.id in ^ids_to_delete)

      attributes = [:document_id, :ancestor_id, :descendant_id, :depth]
      rows_to_insert = Enum.map(find_missing(doc_id), &Map.take(&1, attributes))
      RenewCollab.Repo.insert_all(LayerParenthood, rows_to_insert)
    end)
  end

  def find_missing(doc_id) do
    transitives =
      from a in "layer_parenthood",
        as: :parent_a,
        join: b in "layer_parenthood",
        on: true,
        as: :parent_b,
        where:
          ^doc_id == a.document_id and
            a.id != b.id and a.document_id == b.document_id and b.ancestor_id == a.descendant_id and
            not exists(
              from t in "layer_parenthood",
                where:
                  {t.ancestor_id, t.descendant_id, t.depth} ==
                    {parent_as(:parent_a).ancestor_id, parent_as(:parent_b).descendant_id,
                     parent_as(:parent_a).depth + parent_as(:parent_b).depth},
                select: %{id: t.id}
            ),
        select: %{
          document_id: a.document_id,
          ancestor_id: a.ancestor_id,
          descendant_id: b.descendant_id,
          depth: a.depth + b.depth,
          reason: "transitivity"
        }

    reflexives =
      from m in "layer",
        left_join: y in "layer_parenthood",
        on: {m.id, m.id, 0} == {y.ancestor_id, y.descendant_id, y.depth},
        where: is_nil(y.id),
        select: %{
          document_id: m.document_id,
          ancestor_id: m.id,
          descendant_id: m.id,
          depth: 0,
          reason: "reflexivity"
        }

    RenewCollab.Repo.all(union(transitives, ^reflexives))
  end

  def find_invalids(doc_id) do
    transitives =
      from a in "layer_parenthood",
        join: b in "layer_parenthood",
        on: a.descendant_id == b.ancestor_id,
        where:
          (^doc_id == a.document_id or ^doc_id == b.document_id) and
            {a.document_id, b.document_id} ==
              {parent_as(:parent_query).document_id, parent_as(:parent_query).document_id} and
            a.depth + b.depth == parent_as(:parent_query).depth and
            a.id != parent_as(:parent_query).id and
            b.id != parent_as(:parent_query).id and
            {parent_as(:parent_query).ancestor_id, parent_as(:parent_query).descendant_id} ==
              {a.ancestor_id, b.descendant_id},
        select: %{
          id: a.id
        }

    symmetrics =
      from a in "layer_parenthood",
        where:
          ^doc_id == a.document_id and
            {a.descendant_id, a.ancestor_id} ==
              {parent_as(:parent_query).ancestor_id, parent_as(:parent_query).descendant_id},
        select: %{
          id: a.id
        }

    query =
      from p in "layer_parenthood",
        as: :parent_query,
        where:
          ^doc_id == p.document_id and
            ((p.depth == 0 and p.descendant_id != p.ancestor_id) or
               (p.depth != 0 and p.descendant_id == p.ancestor_id) or
               (p.depth > 1 and not exists(transitives)) or
               (p.depth > 0 and exists(symmetrics))),
        select: %{
          id: p.id
        }

    RenewCollab.Repo.all(query)
  end
end
