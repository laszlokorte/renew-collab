defmodule RenewCollabProj.Commands.RemoveProjectSimulation do
  alias RenewCollabProj.Entities.ProjectSimulation
  import Ecto.Query

  defstruct [:project_id, :simulation_id]

  def new(%{project_id: project_id, simulation_id: simulation_id}) do
    %__MODULE__{project_id: project_id, simulation_id: simulation_id}
  end

  def multi(%__MODULE__{project_id: project_id, simulation_id: simulation_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_assignment,
      from(a in ProjectSimulation,
        where: a.project_id == ^project_id and a.simulation_id == ^simulation_id
      ),
      []
    )
  end
end
