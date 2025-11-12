defmodule RenewCollabProj.Entities.ProjectShadowNetSystem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_shadow_net_system" do
    belongs_to :project, RenewCollabProj.Entities.Project
    belongs_to :shadow_net_system, RenewCollabSim.Entities.ShadowNetSystem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sim, attrs) do
    sim
    |> cast(attrs, [:shadow_net_system_id])
    |> validate_required([:project_id, :shadow_net_system_id])
    |> unique_constraint(:shadow_net_system_id)
  end
end
