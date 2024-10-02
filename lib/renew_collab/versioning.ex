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
      "document-versions-#{document_id}",
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
      "document-undo-redo-#{document_id}",
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
    snapshotters = RenewCollab.Versioning.Snapshotters.snapshotters()

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :latest_snapshot,
        fn %{document_id: document_id} ->
          from(l in LatestSnapshot, where: l.document_id == ^document_id, select: l.snapshot_id)
        end
      )
      |> Ecto.Multi.run(
        :ids,
        fn
          _, %{latest_snapshot: nil} ->
            new_id = Ecto.UUID.generate()

            {:ok,
             %{
               new_id: new_id,
               predecessor_id: new_id
             }}

          _, %{latest_snapshot: predecessor_id} ->
            new_id = Ecto.UUID.generate()

            {:ok,
             %{
               new_id: new_id,
               predecessor_id: predecessor_id
             }}
        end
      )

    snapshotters
    |> Enum.reduce(multi, fn snap, acc ->
      acc
      |> Ecto.Multi.all(snap.storage_key(), fn %{document_id: document_id} ->
        snap.query(document_id)
      end)
    end)
    |> Ecto.Multi.insert_or_update(
      :new_snapshot,
      fn %{
           document_id: document_id,
           ids: %{
             new_id: new_id,
             predecessor_id: predecessor_id
           }
         } =
           results ->
        %Snapshot{document_id: document_id}
        |> Snapshot.changeset(%{
          id: new_id,
          predecessor_id: predecessor_id,
          content:
            snapshotters
            |> Enum.map(& &1.storage_key())
            |> Enum.map(&{&1, Map.get(results, &1)})
            |> Map.new()
        })
      end,
      on_conflict: {:replace, [:content, :updated_at]},
      returning: [:id]
    )
    |> Ecto.Multi.insert(
      :new_latest_snapshot,
      fn %{
           new_snapshot: new_snapshot
         } ->
        %LatestSnapshot{
          document_id: new_snapshot.document_id,
          snapshot_id: new_snapshot.id
        }
      end,
      on_conflict: {:replace, [:snapshot_id]}
    )
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
          RenewCollab.SimpleCache.delete("document-#{document_id}")
          RenewCollab.SimpleCache.delete("document-undo-redo-#{document_id}")
          RenewCollab.SimpleCache.delete("document-versions-#{document_id}")

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "document:#{document_id}",
            {:document_changed, document_id}
          )
        end
    end
  end
end
