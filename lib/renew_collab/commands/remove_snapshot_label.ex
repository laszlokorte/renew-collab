defmodule RenewCollab.Commands.RemoveSnapshotLabel do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot

  defstruct [:document_id, :snapshot_id]

  def new(%{document_id: document_id, snapshot_id: snapshot_id}) do
    %__MODULE__{document_id: document_id, snapshot_id: snapshot_id}
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{document_id: document_id, snapshot_id: snapshot_id}) do
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
  end
end
