defmodule RenewCollabSim.Entites.SimulationNetInstance do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation_net_instance" do
    belongs_to :simulation, RenewCollabSim.Entites.Simulation
    has_many :tokens, RenewCollabSim.Entites.SimulationNetToken
    field :label, :string
  end
end
