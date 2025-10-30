defmodule RenewCollabSim.Commands.RenameSimulation do
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:simulation_id, :new_name]

  def new(%{simulation_id: id, new_name: new_name}) do
    %__MODULE__{simulation_id: id, new_name: new_name}
  end

  def multi(%__MODULE__{simulation_id: id, new_name: new_name}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:sim, from(s in Simulation, where: s.id == ^id))
    |> Ecto.Multi.update(:rename, fn %{sim: sim} ->
      sim |> Simulation.rename_changeset(%{label: new_name})
    end)
  end
end
