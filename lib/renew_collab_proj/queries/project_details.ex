defmodule RenewCollabProj.Queries.ProjectDetails do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:project_id]

  def new(%{project_id: project_id}) do
    %__MODULE__{project_id: project_id}
  end

  def multi(%__MODULE__{project_id: project_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :projects,
      from(
        p in Project,
        where: p.id == ^project_id
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{projects: projects} ->
      {:ok,
       repo.preload(projects, [
         :members,
         :ownerships,
         :documents,
         :shadow_net_systems,
         :simulations,
         :invitations
       ])}
    end)
  end
end
