defmodule RenewCollab.Versioning.Snapshot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "snapshot" do
    field :content, :map
    belongs_to :document, RenewCollab.Document.Document
    belongs_to :predecessor, RenewCollab.Versioning.Snapshot, foreign_key: :predecessor_id
    has_many :successors, RenewCollab.Versioning.Snapshot, foreign_key: :predecessor_id
    has_one :latest, RenewCollab.Versioning.LatestSnapshot

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path, attrs) do
    path
    |> cast(attrs, [:id, :content, :document_id, :predecessor_id])
    |> validate_required([:id, :content, :document_id, :predecessor_id])
  end
end
