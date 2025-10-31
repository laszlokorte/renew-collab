defmodule RenewCollabProj.Queries.DocumentsProject do
  alias RenewCollabProj.Entities.ProjectDocument
  import Ecto.Query

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(p in ProjectDocument,
        join: proj in assoc(p, :project),
        where: p.document_id == ^document_id
      )
    )
  end
end
