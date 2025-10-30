defmodule RenewCollabProj.Commands.AssignProjectSimulation do
  alias RenewCollabProj.Entities.ProjectSimulation

  defstruct [:project_id, :simulation_id]

  def new(%{project_id: project_id, simulation_id: simulation_id}) do
    %__MODULE__{project_id: project_id, simulation_id: simulation_id}
  end

  def multi(%__MODULE__{project_id: project_id, simulation_id: simulation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:insert_assignment, %ProjectSimulation{
      project_id: project_id,
      simulation_id: simulation_id
    })
  end
end
