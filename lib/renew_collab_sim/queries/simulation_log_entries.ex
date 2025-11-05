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
      :result,
      from(sim in Simulation,
        left_join: log in assoc(sim, :log_entries),
        where: sim.id == ^id,
        order_by: [desc: log.inserted_at],
        limit: 10,
        preload: [log_entries: log]
      )
    )
  end
end
