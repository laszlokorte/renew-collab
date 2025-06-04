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
    has_many :ownerships, RenewCollabProj.Entites.ProjectMember, where: [role: :owner]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc false
  def creation_changeset(project, attrs) do
    project
    |> cast(attrs, [:name])
    |> cast_assoc(
      :ownerships,
      with: &RenewCollabProj.Entites.ProjectMember.changeset_creation/2
    )
    |> validate_required([:name])
  end
end
