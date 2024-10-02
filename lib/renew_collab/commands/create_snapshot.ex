defmodule RenewCollab.Commands.CreateSnapshot do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.LatestSnapshot
  @snapshotters RenewCollab.Versioning.Snapshotters.snapshotters()

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.append(multi())
  end

  def multi() do
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

    @snapshotters
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
            @snapshotters
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
end
