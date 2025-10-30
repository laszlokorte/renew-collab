defmodule RenewCollabProj.Commands.DeleteProject do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:project_id]

  def new(%{project_id: project_id}) do
    %__MODULE__{project_id: project_id}
  end

  def multi(%__MODULE__{project_id: project_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_proj, from(p in Project, where: p.id == ^project_id))
  end
end
