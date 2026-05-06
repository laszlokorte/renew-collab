defmodule RenewCollabSim.Queries.SimulationLogEntries do
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: id}) do
    %__MODULE__{simulation_id: id}
  end

  def multi(%__MODULE__{simulation_id: id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :sim,
      from(sim in Simulation,
        where: sim.id == ^id,
        limit: 10
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{sim: sim} ->
      {:ok,
       sim
       |> repo.preload([
         :log_entries
       ])}
    end)
  end
end
