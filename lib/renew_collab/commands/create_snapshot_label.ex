defmodule RenewCollab.Commands.CreateSnapshotLabel do
  import Ecto.Query, warn: false
  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.SnapshotLabel

  defstruct [:document_id, :snapshot_id, :description]

  def new(%{document_id: document_id, snapshot_id: snapshot_id, description: description}) do
    %__MODULE__{document_id: document_id, snapshot_id: snapshot_id, description: description}
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_versions, document_id}]
  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{
        document_id: document_id,
        snapshot_id: snapshot_id,
        description: description
      }) do
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
  end
end
