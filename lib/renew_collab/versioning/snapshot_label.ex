defmodule RenewCollab.Versioning.SnapshotLabel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "snapshot_label" do
    field :description, :string
    belongs_to :snapshot, RenewCollab.Versioning.Snapshot
  end

  @doc false
  def changeset(path, attrs) do
    path
    |> cast(attrs, [:description, :snapshot_id])
    |> validate_required([:description, :snapshot_id])
    |> unique_constraint(:snapshot_id)
  end
end
