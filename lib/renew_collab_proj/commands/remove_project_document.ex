defmodule RenewCollabProj.Commands.RemoveProjectDocument do
  alias RenewCollabProj.Entities.ProjectDocument
  import Ecto.Query

  defstruct [:project_id, :document_id]

  def new(%{project_id: project_id, document_id: document_id}) do
    %__MODULE__{project_id: project_id, document_id: document_id}
  end

  def multi(%__MODULE__{project_id: project_id, document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_assignment,
      from(a in ProjectDocument,
        where: a.project_id == ^project_id and a.document_id == ^document_id
      ),
      []
    )
  end
end
