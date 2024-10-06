defmodule RenewCollab.Commands.PruneSnapshots do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.LatestSnapshot
  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.SnapshotLabel

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.insert_all(
      :new_auto_label,
      SnapshotLabel,
      fn %{document_id: document_id} ->
        from(l in LatestSnapshot,
          where: l.document_id == ^document_id,
          join: s in assoc(l, :snapshot),
          left_join: lbl in assoc(s, :label),
          where: is_nil(lbl.id),
          select: %{
            id: ^Ecto.UUID.generate(),
            snapshot_id: l.snapshot_id,
            description: "(auto)"
          }
        )
      end
    )
    |> Ecto.Multi.update_all(
      :update_predecessors,
      fn %{document_id: document_id} ->
        from(s in Snapshot,
          where:
            s.document_id == ^document_id and
              s.id in subquery(
                from(l in SnapshotLabel,
                  join: ss in assoc(l, :snapshot),
                  where: ss.document_id == ^document_id,
                  select: l.snapshot_id
                )
              ),
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
