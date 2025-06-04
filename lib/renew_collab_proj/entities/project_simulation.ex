defmodule RenewCollabProj.Entites.ProjectSimulation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_simulation" do
    belongs_to :project, RenewCollabProj.Entites.Project
    belongs_to :simulation, RenewCollabSim.Entites.Simulation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sim, attrs) do
    sim
    |> cast(attrs, [:simulation_id])
    |> validate_required([:project_id, :simulation_id])
  end
end
