defmodule RenewCollab.Commands.RestoreSnapshot do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.LatestSnapshot
  alias RenewCollab.Versioning.SnapshotContent

  defstruct [:document_id, :snapshot_id]

  def new(%{document_id: document_id, snapshot_id: snapshot_id}) do
    %__MODULE__{document_id: document_id, snapshot_id: snapshot_id}
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{document_id: document_id, snapshot_id: snapshot_id}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.put(:document_id, document_id)
      |> Ecto.Multi.one(
        :snapshot,
        fn %{document_id: document_id} ->
          from(s in Snapshot,
            join: c in assoc(s, :content),
            preload: [content: c],
            where: s.id == ^snapshot_id and s.document_id == ^document_id
          )
        end
      )
      |> Ecto.Multi.run(
        :snapshot_content,
        fn _, %{snapshot: %Snapshot{content: %SnapshotContent{content: content}}} ->
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
      RenewCollab.Versioning.Snapshotters.snapshotters()
      |> Enum.reduce(multi, fn snap, m ->
        key = snap.storage_key()
        schema = snap.schema()

        m
        |> Ecto.Multi.insert_all({:restore, key}, schema, fn %{
                                                               snapshot_content: content
                                                             } ->
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
  end
end
