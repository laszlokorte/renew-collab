defmodule RenewCollabProj.Commands.AssignProjectMember do
  alias RenewCollabProj.Entities.ProjectMember
  import RenewCollabProj.Entities.ProjectMember, only: [roles_list: 0]

  defstruct [:project_id, :account_id, :role]

  defguard is_member_role(role) when role in roles_list()

  def new(%{project_id: project_id, account_id: account_id, role: role})
      when is_member_role(role) do
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
