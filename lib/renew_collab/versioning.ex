defmodule RenewCollab.Versioning do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.LatestSnapshot
  alias RenewCollab.Versioning.SnapshotLabel
  alias RenewCollab.Repo
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

  def compress(binary) do
    z = :zlib.open()
    :zlib.deflateInit(z)
    compressed = :zlib.deflate(z, binary)
    :zlib.close(z)

    compressed
  end

  def decompress(binary) do
    z = :zlib.open()
    :zlib.inflateInit(z)
    decompressed = :zlib.inflate(z, binary)
    :zlib.close(z)

    decompressed
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
    |> Enum.reduce(multi, fn {key, {_, query}}, acc ->
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
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.append(RenewCollab.Versioning.snapshot_multi())
    |> run_transaction()
  end

  def restore_snapshot(document_id, snapshot_id) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.put(:document_id, document_id)
      |> Ecto.Multi.one(
        :snapshot,
        fn %{document_id: document_id} ->
          from(s in Snapshot, where: s.id == ^snapshot_id and s.document_id == ^document_id)
        end
      )
      |> Ecto.Multi.run(
        :snapshot_content,
        fn _, %{snapshot: %Snapshot{content: content}} ->
          {:ok, content}
        end
      )
      |> Ecto.Multi.delete_all(
        :delete_all_layers,
        fn %{document_id: document_id} ->
          from(l in Layer,
            where: l.document_id == ^document_id
          )
        end
      )

    multi =
      RenewCollab.Versioning.Snapshotter.queries()
      |> Enum.reduce(multi, fn {key, {schema, _}}, m ->
        m
        |> Ecto.Multi.insert_all(String.to_atom("restore_#{key}"), schema, fn %{
                                                                                snapshot_content:
                                                                                  content
                                                                              } ->
          dbg(Map.get(content, key, []))
          Map.get(content, key, [])
        end)
      end)

    multi
    |> Ecto.Multi.insert(
      :new_latest_snapshot,
      fn %{document_id: document_id} ->
        %LatestSnapshot{
          document_id: document_id,
          snapshot_id: snapshot_id
        }
      end,
      on_conflict: {:replace, [:snapshot_id]}
    )
    |> run_transaction()
  end

  def create_snapshot_label(document_id, snapshot_id, description) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :snapshot,
      fn %{document_id: document_id} ->
        from(s in Snapshot, where: s.id == ^snapshot_id and s.document_id == ^document_id)
      end
    )
    |> Ecto.Multi.insert(
      :new_label,
      fn %{
           snapshot: snapshot
         } ->
        %SnapshotLabel{
          description: description,
          snapshot_id: snapshot.id
        }
      end
    )
    |> run_transaction()
  end

  def remove_snapshot_label(document_id, snapshot_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :label,
      fn %{document_id: document_id} ->
        from(s in Snapshot,
          join: l in assoc(s, :label),
          where: s.id == ^snapshot_id and s.document_id == ^document_id,
          select: l
        )
      end
    )
    |> Ecto.Multi.delete(
      :delete_label,
      fn %{
           label: label
         } ->
        label
      end
    )
    |> run_transaction()
  end

  def prune_snaphots(document_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.insert_all(
      :new_auto_label,
      SnapshotLabel,
      fn %{document_id: document_id} ->
        from(l in LatestSnapshot,
          where: l.document_id == ^document_id,
          select: %{
            id: ^Ecto.UUID.generate(),
            snapshot_id: l.snapshot_id,
            description: "(auto)"
          }
        )
      end,
      on_conflict: :nothing
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
          where:
            s.document_id == ^document_id and
              s.id not in subquery(
                from(l in SnapshotLabel,
                  join: ss in assoc(l, :snapshot),
                  where: ss.document_id == ^document_id,
                  select: l.snapshot_id
                )
              )
        )
      end,
      []
    )
    |> run_transaction()
  end

  defp run_transaction(multi) do
    Repo.transaction(multi)
    |> case do
      {:ok, values} ->
        with %{document_id: document_id} <- values do
          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "document:#{document_id}",
            {:document_changed, document_id}
          )
        end
    end
  end
end
