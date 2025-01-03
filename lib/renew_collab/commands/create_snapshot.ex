defmodule RenewCollab.Commands.CreateSnapshot do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.LatestSnapshot
  alias RenewCollab.Versioning.SnapshotContent
  @snapshotters RenewCollab.Versioning.Snapshotters.snapshotters()

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_versions, document_id}]
  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.append(multi(document_id))
  end

  def multi(document_id) when is_binary(document_id) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :latest_snapshot,
        from(l in LatestSnapshot, where: l.document_id == ^document_id, select: l.snapshot_id)
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

    @snapshotters
    |> Enum.reduce(multi, fn snap, acc ->
      acc
      |> Ecto.Multi.all(snap.storage_key(), fn %{} ->
        snap.query(document_id)
      end)
    end)
    |> Ecto.Multi.delete_all(
      :delete_current_latest,
      fn %{} ->
        from(l in LatestSnapshot, where: l.document_id == ^document_id)
      end,
      []
    )
    |> RenewCollab.Compatibility.Multi.insert(
      :new_snapshot,
      fn %{
           ids: %{
             new_id: new_id,
             predecessor_id: predecessor_id
           }
         } ->
        %Snapshot{document_id: document_id}
        |> Snapshot.changeset(%{
          id: new_id,
          predecessor_id: predecessor_id
        })
      end,
      on_conflict: {:replace, [:id, :updated_at]},
      conflict_target: [:document_id, :inserted_at]
    )
    |> RenewCollab.Compatibility.Multi.insert(
      :new_snapshot_content,
      fn %{
           ids: %{
             new_id: new_id
           }
         } =
           results ->
        %SnapshotContent{snapshot_id: new_id}
        |> SnapshotContent.changeset(%{
          content:
            @snapshotters
            |> Enum.map(& &1.storage_key())
            |> Enum.map(&{&1, Map.get(results, &1)})
            |> Map.new()
        })
      end,
      on_conflict: {:replace, [:content]},
      conflict_target: [:snapshot_id]
    )
    |> RenewCollab.Compatibility.Multi.insert(
      :new_latest_snapshot,
      fn %{
           ids: %{
             new_id: new_id
           }
         } ->
        %LatestSnapshot{
          document_id: document_id,
          snapshot_id: new_id
        }
      end,
      on_conflict: {:replace, [:snapshot_id]},
      conflict_target: [:document_id]
    )
  end
end
