defmodule RenewCollab.Versioning do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.LatestSnapshot
  alias RenewCollab.Repo
  alias RenewCollab.Commands

  def document_versions(document_id) do
    query =
      from(s in Snapshot,
        where: s.document_id == ^document_id,
        left_join: l in assoc(s, :latest),
        left_join: lb in assoc(s, :label),
        select: %{
          id: s.id,
          inserted_at: s.inserted_at,
          is_latest: not is_nil(l.id),
          label: lb.description
        },
        order_by: [desc: s.inserted_at]
      )

    RenewCollab.SimpleCache.cache(
      {:versions, document_id},
      fn ->
        query |> Repo.all()
      end,
      600
    )
  end

  def document_undo_redo(document_id) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :undo,
        from(s in Snapshot,
          join: l in LatestSnapshot,
          on: l.snapshot_id == s.id,
          left_join: p in Snapshot,
          on: s.predecessor_id == p.id and p.id != s.id,
          where: s.document_id == ^document_id,
          select: p.id
        )
      )
      |> Ecto.Multi.all(
        :redos,
        from(s in Snapshot,
          join: l in LatestSnapshot,
          on: l.snapshot_id == s.id,
          join: suc in Snapshot,
          on: s.id == suc.predecessor_id,
          where: s.document_id == ^document_id and suc.id != suc.predecessor_id,
          select: suc.id
        )
      )

    RenewCollab.SimpleCache.cache(
      {:undo_redo, document_id},
      fn ->
        multi
        |> Repo.transaction()
        |> case do
          {:ok, %{undo: undo_id, redos: redo_ids}} ->
            %{
              predecessor_id: undo_id,
              successors: redo_ids
            }
        end
      end,
      600
    )
  end

  def snapshot_multi() do
    RenewCollab.Commands.CreateSnapshot.multi()
  end

  def create_snapshot(document_id) do
    Commands.CreateSnapshot.new(%{document_id: document_id})
    |> Commands.CreateSnapshot.multi()
    |> run_transaction()
  end

  def restore_snapshot(document_id, snapshot_id) do
    Commands.RestoreSnapshot.new(%{document_id: document_id, snapshot_id: snapshot_id})
    |> Commands.RestoreSnapshot.multi()
    |> run_transaction()
  end

  def create_snapshot_label(document_id, snapshot_id, description) do
    Commands.CreateSnapshotLabel.new(%{
      document_id: document_id,
      snapshot_id: snapshot_id,
      description: description
    })
    |> Commands.CreateSnapshotLabel.multi()
    |> run_transaction()
  end

  def remove_snapshot_label(document_id, snapshot_id) do
    Commands.RemoveSnapshotLabel.new(%{document_id: document_id, snapshot_id: snapshot_id})
    |> Commands.RemoveSnapshotLabel.multi()
    |> run_transaction()
  end

  def prune_snaphots(document_id) do
    Commands.PruneSnapshots.new(%{document_id: document_id})
    |> Commands.PruneSnapshots.multi()
    |> run_transaction()
  end

  defp run_transaction(multi) do
    Repo.transaction(multi)
    |> case do
      {:ok, values} ->
        with %{document_id: document_id} <- values do
          RenewCollab.SimpleCache.delete({:document, document_id})
          RenewCollab.SimpleCache.delete({:undo_redo, document_id})
          RenewCollab.SimpleCache.delete({:versions, document_id})

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "document:#{document_id}",
            {:document_changed, document_id}
          )
        end
    end
  end
end
