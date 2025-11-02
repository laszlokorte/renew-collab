defmodule RenewCollabProj.Commands.UpdateProjectMeta do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:project_id, :attributes]

  def new(%{project_id: project_id, attributes: attributes}) do
    %__MODULE__{project_id: project_id, attributes: attributes}
  end

  def multi(%__MODULE__{project_id: project_id, attributes: attributes}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :project,
      from(proj in Project,
        where: proj.id == ^project_id
      )
    )
    |> Ecto.Multi.update(:change_project, fn %{project: project} ->
      Project.changeset(project, attributes)
    end)
  end
end
