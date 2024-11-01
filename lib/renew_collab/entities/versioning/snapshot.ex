defmodule RenewCollab.Versioning.Snapshot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "snapshot" do
    belongs_to :document, RenewCollab.Document.Document
    belongs_to :predecessor, RenewCollab.Versioning.Snapshot, foreign_key: :predecessor_id

    has_many :successors, RenewCollab.Versioning.Snapshot, foreign_key: :predecessor_id
    # where: [id: {:fragment, "? <> predecessor_id"}]
    # TODO: add condition above to exclude reflexive versions

    has_one :latest, RenewCollab.Versioning.LatestSnapshot
    has_one :label, RenewCollab.Versioning.SnapshotLabel
    has_one :content, RenewCollab.Versioning.SnapshotContent

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path, attrs) do
    path
    |> cast(attrs, [:id, :document_id, :predecessor_id])
    |> cast_assoc(:content)
    |> validate_required([:id, :document_id, :predecessor_id])
  end
end
