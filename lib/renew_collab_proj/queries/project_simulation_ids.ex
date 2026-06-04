defmodule RenewCollabProj.Queries.ProjectSimulationIds do
  alias RenewCollabProj.Entities.ProjectSimulation
  import Ecto.Query

  defstruct [:project_id]

  def new(%{project_id: project_id}) do
    %__MODULE__{project_id: project_id}
  end

  def multi(%__MODULE__{project_id: project_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(ps in ProjectSimulation,
        where: ps.project_id == ^project_id,
        select: ps.simulation_id
      )
    )
  end
end
