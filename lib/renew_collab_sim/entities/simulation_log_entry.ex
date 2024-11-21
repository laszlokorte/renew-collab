defmodule RenewCollabSim.Entites.SimulationLogEntry do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shadow_net_sytem" do
    belongs_to :simulation, RenewCollabSim.Entites.Simulation

    timestamps(type: :utc_datetime)
  end
end
