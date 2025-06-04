defmodule RenewCollabSim.Entites.Simulation do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation" do
    belongs_to :shadow_net_system, RenewCollabSim.Entites.ShadowNetSystem

    has_many :log_entries, RenewCollabSim.Entites.SimulationLogEntry,
      preload_order: [asc: :inserted_at]

    has_many :net_instances, RenewCollabSim.Entites.SimulationNetInstance,
      preload_order: [asc: :label, asc: :integer_id]

    field :timestep, :integer, default: 0

    has_one :project_assignment, RenewCollabProj.Entites.ProjectSimulation
    has_one :project, through: [:project_assignment, :project]

    timestamps(type: :utc_datetime)
  end
end
