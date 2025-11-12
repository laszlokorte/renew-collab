defmodule RenewCollabProj.Entities.ProjectMedia do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_media" do
    belongs_to :project, RenewCollabProj.Entities.Project
    belongs_to :media, RenewCollab.Media.Svg

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(doc, attrs) do
    doc
    |> cast(attrs, [:media_id])
    |> validate_required([:project_id, :media_id])
    |> unique_constraint([:media_id])
  end
end
