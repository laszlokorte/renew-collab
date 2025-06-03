defmodule RenewCollabProj.Entites.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project" do
    field :name, :string

    has_many :documents, RenewCollabProj.Entites.ProjectDocument
    has_many :simulations, RenewCollabProj.Entites.ProjectSimulation
    has_many :members, RenewCollabProj.Entites.ProjectMember

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
