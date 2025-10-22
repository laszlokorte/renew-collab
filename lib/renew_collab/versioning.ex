defmodule RenewCollab.Versioning do
  def document_versions(document_id) do
    :deprecated
  end

  def document_undo_redo(document_id) do
    :deprecated
  end

  def snapshot_multi(document_id) do
    # dbg(document_id)
    RenewCollab.Commands.CreateSnapshot.multi(document_id)
  end
end
