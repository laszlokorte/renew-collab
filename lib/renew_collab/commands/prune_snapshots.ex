defmodule RenewCollab.Commands.PruneSnapshots do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.LatestSnapshot
  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.SnapshotLabel

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_versions, document_id}]

  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :find_latest,
      from(l in LatestSnapshot,
        where: l.document_id == ^document_id,
        join: s in assoc(l, :snapshot),
        select: s.id
      )
    )
    |> Ecto.Multi.insert(
      :new_auto_label,
      fn %{find_latest: latest_id} ->
        %SnapshotLabel{
          snapshot_id: latest_id,
          description: "(auto)"
        }
      end,
      on_conflict: :nothing
    )
    |> Ecto.Multi.update_all(
      :update_predecessors,
      fn %{document_id: document_id} ->
        from(s in Snapshot,
          where: s.document_id == ^document_id,
          update: [set: [predecessor_id: s.id]]
        )
      end,
      []
    )
    |> Ecto.Multi.delete_all(
      :delete_label,
      fn %{document_id: document_id} ->
        from(s in Snapshot,
          as: :s,
          where:
            s.document_id == ^document_id and
              s.id not in subquery(
                from(l in SnapshotLabel,
                  where: l.snapshot_id == parent_as(:s).id,
                  select: l.snapshot_id
                )
              )
        )
      end,
      []
    )
  end
end
