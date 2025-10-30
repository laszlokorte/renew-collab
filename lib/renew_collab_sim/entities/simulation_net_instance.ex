defmodule RenewCollabSim.Entities.SimulationNetInstance do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation_net_instance" do
    belongs_to(:simulation, RenewCollabSim.Entities.Simulation)
    belongs_to(:shadow_net_system, RenewCollabSim.Entities.ShadowNetSystem)
    belongs_to(:shadow_net, RenewCollabSim.Entities.ShadowNet)
    has_many(:tokens, RenewCollabSim.Entities.SimulationNetToken, preload_order: [asc: :place_id])

    has_many(:firings, RenewCollabSim.Entities.SimulationTransitionFiring,
      preload_order: [asc: :timestep, asc: :id]
    )

    field(:label, :string)
    field(:integer_id, :integer)
  end
end
