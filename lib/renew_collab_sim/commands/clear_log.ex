defmodule RenewCollabSim.Commands.ClearLog do
  alias RenewCollabSim.Entities.SimulationLogEntry
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: simulation_id}) do
    %__MODULE__{simulation_id: simulation_id}
  end

  def multi(%__MODULE__{simulation_id: simulation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      from(l in SimulationLogEntry,
        where: l.simulation_id == ^simulation_id
      ),
      []
    )
  end
end
