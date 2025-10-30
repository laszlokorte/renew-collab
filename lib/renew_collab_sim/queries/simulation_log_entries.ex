defmodule RenewCollabSim.Queries.SimulationLogEntries do
  import Ecto.Query

  defstruct [:simulation_id]

  def new(%{simulation_id: id}) do
    %__MODULE__{simulation_id: id}
  end

  def multi(%__MODULE__{simulation_id: id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(sl in SimulationLogEntry,
        where: sl.simulation_id == ^id,
        order_by: [desc: sl.inserted_at],
        limit: 10
      )
    )
  end
end
