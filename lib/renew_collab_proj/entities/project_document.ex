defmodule RenewCollabProj.Entites.ProjectDocument do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_document" do
    belongs_to :project, RenewCollabProj.Entites.Project
    belongs_to :document, RenewCollab.Document.Document

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(doc, attrs) do
    doc
    |> cast(attrs, [:document_id])
    |> validate_required([:project_id, :document_id])
  end
end
