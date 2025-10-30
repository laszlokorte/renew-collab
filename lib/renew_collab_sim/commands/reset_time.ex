defmodule RenewCollabSim.Commands.ResetTime do
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: simulation_id}) do
    %__MODULE__{simulation_id: simulation_id}
  end

  def multi(%__MODULE__{simulation_id: simulation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.update_all(
      from(s in Simulation,
        where: s.id == ^simulation_id,
        update: [set: [timestep: 0]]
      ),
      []
    )
  end
end
