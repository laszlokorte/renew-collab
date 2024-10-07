defmodule RenewCollab.Versioning.SnapshotContent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "snapshot_content" do
    field :content, RenewCollab.Versioning.CompressedMap
    belongs_to :snapshot, RenewCollab.Versioning.Snapshot
  end

  @doc false
  def changeset(path, attrs) do
    path
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
