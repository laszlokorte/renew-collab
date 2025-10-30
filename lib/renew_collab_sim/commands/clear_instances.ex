defmodule RenewCollabSim.Commands.ClearInstances do
  alias RenewCollabSim.Entites.SimulationTransitionFiring
  alias RenewCollabSim.Entites.SimulationNetInstance
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: simulation_id}) do
    %__MODULE__{simulation_id: simulation_id}
  end

  def multi(%__MODULE__{simulation_id: simulation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :instances,
      from(l in SimulationNetInstance,
        where: l.simulation_id == ^simulation_id
      )
    )
    |> Ecto.Multi.delete_all(
      :firings,
      from(l in SimulationTransitionFiring,
        where: l.simulation_id == ^simulation_id
      )
    )
  end
end
