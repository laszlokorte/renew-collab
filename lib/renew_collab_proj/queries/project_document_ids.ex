defmodule RenewCollabProj.Queries.ProjectDocumentIds do
  alias RenewCollabProj.Entities.ProjectDocument
  import Ecto.Query

  defstruct [:project_id]

  def new(%{project_id: project_id}) do
    %__MODULE__{project_id: project_id}
  end

  def multi(%__MODULE__{project_id: project_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(pd in ProjectDocument,
        where: pd.project_id == ^project_id,
        select: pd.document_id
      )
    )
  end
end
