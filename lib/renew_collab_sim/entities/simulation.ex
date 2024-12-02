defmodule RenewCollabSim.Entites.Simulation do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation" do
    belongs_to :shadow_net_system, RenewCollabSim.Entites.ShadowNetSystem

    has_many :log_entries, RenewCollabSim.Entites.SimulationLogEntry,
      preload_order: [asc: :inserted_at, asc: :rowid]

    has_many :net_instances, RenewCollabSim.Entites.SimulationNetInstance

    field :timestep, :integer, default: 0

    timestamps(type: :utc_datetime)
  end
end
