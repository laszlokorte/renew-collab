defmodule RenewCollab.Hierarchy do
  import Ecto.Query, only: [from: 2, union: 2]

  alias RenewCollab.Hierarchy.LayerParenthood

  @attributes [:document_id, :ancestor_id, :descendant_id, :depth]

  def repair_parenthood(doc_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, doc_id)
    |> Ecto.Multi.run(
      :invalids,
      fn _,
         %{
           document_id: document_id
         } ->
        {:ok, Enum.map(find_invalids(document_id), & &1.id)}
      end
    )
    |> Ecto.Multi.delete_all(:delete_invalid, fn %{invalids: ids_to_delete} ->
      from(p in LayerParenthood, where: p.id in ^ids_to_delete)
    end)
    |> Ecto.Multi.run(
      :missings,
      fn _,
         %{
           document_id: document_id
         } ->
        {:ok, Enum.map(find_missing(document_id), &Map.take(&1, @attributes))}
      end
    )
    |> Ecto.Multi.insert_all(:insert_missings, LayerParenthood, fn %{missings: rows_to_insert} ->
      rows_to_insert
    end)
    |> RenewCollab.Repo.transaction()
  end

  def find_missing_query(doc_id) do
    transitives =
      from a in LayerParenthood,
        as: :parent_a,
        join: b in LayerParenthood,
        on: true,
        as: :parent_b,
        where:
          ^doc_id == a.document_id and
            a.id != b.id and a.document_id == b.document_id and b.ancestor_id == a.descendant_id and
            not exists(
              from t in LayerParenthood,
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
          reason: :transitivity
        }

    reflexives =
      from m in "layer",
        left_join: y in LayerParenthood,
        on: {m.id, m.id, 0} == {y.ancestor_id, y.descendant_id, y.depth},
        where: is_nil(y.id),
        select: %{
          document_id: m.document_id,
          ancestor_id: m.id,
          descendant_id: m.id,
          depth: 0,
          reason: :reflexivity
        }

    union(transitives, ^reflexives)
  end

  def find_missing_query() do
    transitives =
      from a in LayerParenthood,
        as: :parent_a,
        join: b in LayerParenthood,
        on: true,
        as: :parent_b,
        where:
          a.id != b.id and a.document_id == b.document_id and b.ancestor_id == a.descendant_id and
            not exists(
              from t in LayerParenthood,
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
          reason: :transitivity
        }

    reflexives =
      from m in "layer",
        left_join: y in LayerParenthood,
        on: {m.id, m.id, 0} == {y.ancestor_id, y.descendant_id, y.depth},
        where: is_nil(y.id),
        select: %{
          document_id: m.document_id,
          ancestor_id: m.id,
          descendant_id: m.id,
          depth: 0,
          reason: :reflexivity
        }

    union(transitives, ^reflexives)
  end

  def find_missing(doc_id) do
    RenewCollab.SimpleCache.cache(
      {:hierarchy_missing, doc_id},
      fn ->
        RenewCollab.Repo.all(find_missing_query(doc_id))
      end,
      600
    )
  end

  def count_missing_global() do
    RenewCollab.Repo.all(find_missing_query()) |> Enum.count()
  end

  def find_invalids_query(doc_id) do
    transitives =
      from a in LayerParenthood,
        join: b in LayerParenthood,
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
      from a in LayerParenthood,
        where:
          ^doc_id == a.document_id and
            {a.descendant_id, a.ancestor_id} ==
              {parent_as(:parent_query).ancestor_id, parent_as(:parent_query).descendant_id},
        select: %{
          id: a.id
        }

    from p in LayerParenthood,
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
  end

  def find_invalids_query() do
    transitives =
      from a in LayerParenthood,
        join: b in LayerParenthood,
        on: a.descendant_id == b.ancestor_id,
        where:
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
      from a in LayerParenthood,
        where:
          {a.descendant_id, a.ancestor_id} ==
            {parent_as(:parent_query).ancestor_id, parent_as(:parent_query).descendant_id},
        select: %{
          id: a.id
        }

    from p in LayerParenthood,
      as: :parent_query,
      where:
        (p.depth == 0 and p.descendant_id != p.ancestor_id) or
          (p.depth != 0 and p.descendant_id == p.ancestor_id) or
          (p.depth > 1 and not exists(transitives)) or
          (p.depth > 0 and exists(symmetrics)),
      select: %{
        id: p.id
      }
  end

  def find_invalids(doc_id) do
    RenewCollab.SimpleCache.cache(
      {:hierarchy_invalids, doc_id},
      fn ->
        RenewCollab.Repo.all(find_invalids_query(doc_id))
      end,
      600
    )
  end

  def count_invalids_global() do
    RenewCollab.Repo.all(find_invalids_query()) |> Enum.count()
  end
end
