defmodule RenewCollabSim.Commands.DeleteSimulation do
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: sim_id}) do
    %__MODULE__{simulation_id: sim_id}
  end

  def multi(%__MODULE__{simulation_id: sim_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_sim, from(s in Simulation, where: s.id == ^sim_id))
  end
end
