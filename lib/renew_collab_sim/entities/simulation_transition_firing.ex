defmodule RenewCollabSim.Entities.SimulationTransitionFiring do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "simulation_transition_firing" do
    belongs_to(:simulation, RenewCollabSim.Entities.Simulation)
    belongs_to(:simulation_net_instance, RenewCollabSim.Entities.SimulationNetInstance)
    field(:transition_id, :binary)
    field(:timestep, :integer)
  end
end
