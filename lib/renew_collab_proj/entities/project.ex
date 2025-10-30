defmodule RenewCollabProj.Entities.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project" do
    field :name, :string

    has_many :documents, RenewCollabProj.Entities.ProjectDocument
    has_many :simulations, RenewCollabProj.Entities.ProjectSimulation
    has_many :shadow_net_systems, RenewCollabProj.Entities.ProjectShadowNetSystem
    has_many :members, RenewCollabProj.Entities.ProjectMember
    has_many :ownerships, RenewCollabProj.Entities.ProjectMember, where: [role: :owner]

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
      with: &RenewCollabProj.Entities.ProjectMember.changeset_creation/2
    )
    |> validate_required([:name])
  end
end
