defmodule RenewCollabSim.Commands.AddManualLogEntry do
  alias RenewCollabSim.Entites.SimulationLogEntry
  import Ecto.Query

  defstruct [:simulation_id, :log_message]

  def new(%{simulation_id: simulation_id, log_message: log_message}) do
    %__MODULE__{simulation_id: simulation_id, log_message: log_message}
  end

  def multi(%__MODULE__{simulation_id: simulation_id, log_message: log_message}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:log_entry, %SimulationLogEntry{
      simulation_id: simulation_id,
      content: log_message
    })
  end
end
