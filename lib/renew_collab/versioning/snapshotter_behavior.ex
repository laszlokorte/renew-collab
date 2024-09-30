defmodule RenewCollab.Versioning.SnapshotterBehavior do
  @callback storage_key() :: atom
  @callback schema() :: atom
  @callback query(document_id :: integer()) :: map
end
