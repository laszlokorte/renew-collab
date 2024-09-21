defmodule RenewCollab.Versioning.Snapshot do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "snapshot" do
    field :content, :map
    belongs_to :document, RenewCollab.Document.Document

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path, attrs) do
    path
    |> cast(attrs, [:content, :document_id])
    |> validate_required([:content, :document_id])
  end
end
