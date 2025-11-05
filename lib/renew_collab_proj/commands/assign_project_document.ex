defmodule RenewCollabProj.Commands.AssignProjectDocument do
  alias RenewCollabProj.Entities.ProjectDocument

  defstruct [:project_id, :document_id, :allow_move]

  def new(%{project_id: project_id, document_id: document_id, allow_move: allow_move}) do
    %__MODULE__{project_id: project_id, document_id: document_id, allow_move: allow_move}
  end

  def new(%{project_id: project_id, document_id: document_id}) do
    %__MODULE__{project_id: project_id, document_id: document_id}
  end

  def multi(%__MODULE__{project_id: project_id, document_id: document_id, allow_move: allow_move}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :insert_assignment,
      %ProjectDocument{
        project_id: project_id,
        document_id: document_id
      },
      on_conflict: if(allow_move, do: {:replace, :project_id}, else: :raise)
    )
  end
end
