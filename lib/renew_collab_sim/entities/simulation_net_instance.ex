defmodule RenewCollabSim.Entites.SimulationNetInstance do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation_net_instance" do
    belongs_to :simulation, RenewCollabSim.Entites.Simulation
    belongs_to :shadow_net_system, RenewCollabSim.Entites.ShadowNetSystem
    belongs_to :shadow_net, RenewCollabSim.Entites.ShadowNet
    has_many :tokens, RenewCollabSim.Entites.SimulationNetToken

    has_many :firings, RenewCollabSim.Entites.SimulationTransitionFiring,
      preload_order: [asc: :timestep, asc: :id]

    field :label, :string
    field :integer_id, :integer
  end
end
