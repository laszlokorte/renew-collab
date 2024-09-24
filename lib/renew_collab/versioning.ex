defmodule RenewCollab.Versioning do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.LatestSnapshot
  alias RenewCollab.Versioning.SnapshotLabel
  alias RenewCollab.Repo
  alias RenewCollab.Renew
  alias RenewCollab.Hierarchy.Layer

  def document_versions(document_id) do
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
    |> Repo.all()
  end

  def document_undo_redo(document_id) do
    from(s in Snapshot,
      join: l in LatestSnapshot,
      on: l.snapshot_id == s.id,
      where: s.document_id == ^document_id
    )
    |> Repo.one()
    |> Repo.preload(successors: [], predecessor: [])
  end

  def snapshot_multi() do
    queries = RenewCollab.Versioning.Snapshotter.queries()

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

    queries
    |> Enum.reduce(multi, fn {key, query}, acc ->
      acc
      |> Ecto.Multi.all(key, fn %{document_id: document_id} ->
        query.(document_id)
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
            Keyword.keys(queries)
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
         } =
           results ->
        %LatestSnapshot{
          document_id: new_snapshot.document_id,
          snapshot_id: new_snapshot.id
        }
      end,
      on_conflict: {:replace, [:snapshot_id]}
    )
  end

  def create_snapshot(document_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.append(RenewCollab.Versioning.snapshot_multi())
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end

  def restore_snapshot(document_id, snapshot_id) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :snapshot,
        from(s in Snapshot, where: s.id == ^snapshot_id and s.document_id == ^document_id)
      )
      |> Ecto.Multi.run(
        :snapshot_content,
        fn _, %{snapshot: %Snapshot{content: content}} ->
          {:ok, content}
        end
      )
      |> Ecto.Multi.delete_all(
        :delete_all_layers,
        fn
          %{} ->
            from(l in Layer,
              where: l.document_id == ^document_id
            )
        end
      )

    multi =
      RenewCollab.Versioning.Snapshotter.insertions()
      |> Enum.reduce(multi, fn {key, schema, func}, m ->
        m
        |> Ecto.Multi.insert_all(String.to_atom("restore_#{key}"), schema, fn %{
                                                                                snapshot_content:
                                                                                  content
                                                                              } ->
          func.(Map.get(content, Atom.to_string(key)))
        end)
      end)

    multi
    |> Ecto.Multi.insert(
      :new_latest_snapshot,
      %LatestSnapshot{
        document_id: document_id,
        snapshot_id: snapshot_id
      },
      on_conflict: {:replace, [:snapshot_id]}
    )
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end

  def create_snapshot_label(document_id, snapshot_id, description) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :snapshot,
      from(s in Snapshot, where: s.id == ^snapshot_id and s.document_id == ^document_id)
    )
    |> Ecto.Multi.insert(
      :new_label,
      fn %{
           snapshot: snapshot
         } =
           results ->
        %SnapshotLabel{
          description: description,
          snapshot_id: snapshot.id
        }
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end

  def remove_snapshot_label(document_id, snapshot_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :label,
      from(s in Snapshot,
        join: l in assoc(s, :label),
        where: s.id == ^snapshot_id and s.document_id == ^document_id,
        select: l
      )
    )
    |> Ecto.Multi.delete(
      :delete_label,
      fn %{
           label: label
         } ->
        label
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end

  def prune_snaphots(document_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_all(
      :new_auto_label,
      SnapshotLabel,
      from(l in LatestSnapshot,
        where: l.document_id == ^document_id,
        select: %{
          id: ^Ecto.UUID.generate(),
          snapshot_id: l.snapshot_id,
          description: "(auto)"
        }
      ),
      on_conflict: :nothing
    )
    |> Ecto.Multi.update_all(
      :update_predecessors,
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
      ),
      []
    )
    |> Ecto.Multi.delete_all(
      :delete_label,
      from(s in Snapshot,
        where:
          s.document_id == ^document_id and
            s.id not in subquery(
              from(l in SnapshotLabel,
                join: ss in assoc(l, :snapshot),
                where: ss.document_id == ^document_id,
                select: l.snapshot_id
              )
            )
      ),
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end
end
