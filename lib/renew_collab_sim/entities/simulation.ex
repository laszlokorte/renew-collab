defmodule RenewCollabSim.Entites.Simulation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation" do
    belongs_to :shadow_net_system, RenewCollabSim.Entites.ShadowNetSystem
    has_many :log_entries, RenewCollabSim.Entites.SimulationLogEntry

    timestamps(type: :utc_datetime)
  end
end
