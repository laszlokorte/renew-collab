defmodule RenewCollabProj.Queries.SimulationsProject do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: simulation_id}) do
    %__MODULE__{simulation_id: simulation_id}
  end

  def multi(%__MODULE__{simulation_id: simulation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(p in Project,
        join: sim in assoc(p, :simulations),
        where: sim.simulation_id == ^simulation_id
      )
    )
  end
end
