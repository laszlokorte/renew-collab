defmodule RenewCollabSim.Commands.ClearSimulation do
  alias RenewCollabSim.Entities.SimulationNetInstance
  alias RenewCollabSim.Entities.SimulationLogEntry
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: simulation_id}) do
    %__MODULE__{simulation_id: simulation_id}
  end

  def multi(%__MODULE__{simulation_id: simulation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_log,
      from(l in SimulationLogEntry,
        where: l.simulation_id == ^simulation_id
      ),
      []
    )
    |> Ecto.Multi.delete_all(
      :delete_instances,
      from(l in SimulationNetInstance,
        where: l.simulation_id == ^simulation_id
      ),
      []
    )
    |> Ecto.Multi.update_all(
      :reset_time,
      from(l in Simulation,
        where: l.id == ^simulation_id
      ),
      set: [timestep: 0]
    )
  end
end
