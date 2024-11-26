defmodule RenewCollabSim.Entites.SimulationNetToken do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation_net_token" do
    belongs_to :simulation, RenewCollabSim.Entites.Simulation
    belongs_to :simulation_net_instance, RenewCollabSim.Entites.SimulationNetInstance
    field :place_id, :binary
    field :value, :string
  end
end
