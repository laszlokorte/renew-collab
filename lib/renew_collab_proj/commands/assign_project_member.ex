defmodule RenewCollabProj.Commands.AssignProjectMember do
  alias RenewCollabProj.Entities.ProjectMember

  defstruct [:project_id, :account_id, :role]

  def new(%{project_id: project_id, account_id: account_id, role: role}) do
    %__MODULE__{project_id: project_id, account_id: account_id, role: role}
  end

  def multi(%__MODULE__{project_id: project_id, account_id: account_id, role: role}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:insert_assignment, %ProjectMember{
      project_id: project_id,
      account_id: account_id,
      role: role
    })
  end
end
