defmodule RenewCollab.Queries.UndoRedoState do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Versioning.LatestSnapshot

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{
      document_id: document_id
    }
  end

  def multi(%__MODULE__{document_id: document_id}) do
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
    |> Ecto.Multi.run(:result, fn _, %{undo: undo_id, redos: redo_ids} ->
      {:ok,
       %{
         predecessor_id: undo_id,
         successors: redo_ids
       }}
    end)
  end
end
