defmodule RenewCollabProj.Commands.AssignProjectDocument do
  alias RenewCollabProj.Entities.ProjectDocument

  defstruct [:project_id, :document_id]

  def new(%{project_id: project_id, document_id: document_id}) do
    %__MODULE__{project_id: project_id, document_id: document_id}
  end

  def multi(%__MODULE__{project_id: project_id, document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:insert_assignment, %ProjectDocument{
      project_id: project_id,
      document_id: document_id
    })
  end
end
