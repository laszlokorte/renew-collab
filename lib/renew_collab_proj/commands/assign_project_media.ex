defmodule RenewCollabProj.Commands.AssignProjectMedia do
  alias RenewCollabProj.Entities.ProjectMedia

  defstruct [:project_id, :media_id]

  def new(%{project_id: project_id, media_id: media_id}) do
    %__MODULE__{project_id: project_id, media_id: media_id}
  end

  def multi(%__MODULE__{project_id: project_id, media_id: media_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:insert_assignment, %ProjectMedia{
      project_id: project_id,
      media_id: media_id
    })
  end
end
