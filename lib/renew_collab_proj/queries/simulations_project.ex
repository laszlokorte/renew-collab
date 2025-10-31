defmodule RenewCollabProj.Queries.SimulationsProject do
  alias RenewCollabProj.Entities.ProjectSimulation
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: simulation_id}) do
    %__MODULE__{simulation_id: simulation_id}
  end

  def multi(%__MODULE__{simulation_id: simulation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(p in ProjectSimulation,
        join: proj in assoc(p, :project),
        where: p.simulation_id == ^simulation_id
      )
    )
  end
end
