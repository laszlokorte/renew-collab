defmodule RenewCollabSim.Entities.Simulation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation" do
    belongs_to :shadow_net_system, RenewCollabSim.Entities.ShadowNetSystem

    has_many :log_entries, RenewCollabSim.Entities.SimulationLogEntry,
      preload_order: [asc: :inserted_at]

    has_many :net_instances, RenewCollabSim.Entities.SimulationNetInstance,
      preload_order: [asc: :label, asc: :integer_id]

    field :label, :string, default: nil
    field :timestep, :integer, default: 0

    has_one :project_assignment, RenewCollabProj.Entities.ProjectSimulation
    has_one :project, through: [:project_assignment, :project]

    has_many :document_links, RenewCollab.Simulation.SimulationLink

    timestamps(type: :utc_datetime)
  end

  @doc false
  def rename_changeset(simulation, attrs) do
    simulation
    |> cast(attrs, [:label], empty_values: [""])
  end
end
