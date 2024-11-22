defmodule RenewCollabSim.Entites.SimulationLogEntry do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation_log_entry" do
    belongs_to :simulation, RenewCollabSim.Entites.Simulation
    field :content, :string

    timestamps(type: :utc_datetime)
  end
end
