defmodule RenewCollab.Versioning do
  def snapshot_multi(document_id) do
    # dbg(document_id)
    RenewCollab.Commands.CreateSnapshot.multi(document_id)
  end
end
