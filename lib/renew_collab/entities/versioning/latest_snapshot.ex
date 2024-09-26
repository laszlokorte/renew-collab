defmodule RenewCollab.Versioning.LatestSnapshot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "latest_snapshot" do
    belongs_to :document, RenewCollab.Document.Document
    belongs_to :snapshot, RenewCollab.Versioning.Snapshot
  end
end
