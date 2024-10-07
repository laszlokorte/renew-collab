defmodule RenewCollab.Versioning do
  def document_versions(document_id) do
    %{document_id: document_id}
    |> RenewCollab.Queries.DocumentVersions.new()
    |> RenewCollab.Fetcher.fetch()
  end

  def document_undo_redo(document_id) do
    %{document_id: document_id}
    |> RenewCollab.Queries.UndoRedoState.new()
    |> RenewCollab.Fetcher.fetch()
  end

  def snapshot_multi() do
    RenewCollab.Commands.CreateSnapshot.multi()
  end
end
