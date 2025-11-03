defmodule RenewCollabProj.Commands.RemoveProjectMember do
  alias RenewCollabProj.Entities.ProjectMember
  import Ecto.Query

  defstruct [:project_id, :account_or_member_id]

  def new(%{project_id: project_id, account_id: account_id}) do
    %__MODULE__{project_id: project_id, account_or_member_id: {:account, account_id}}
  end

  def new(%{project_id: project_id, member_id: member_id}) do
    %__MODULE__{project_id: project_id, account_or_member_id: {:member, member_id}}
  end

  def multi(%__MODULE__{project_id: project_id, account_or_member_id: {:account, account_id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_assignment,
      from(m in ProjectMember,
        where: m.project_id == ^project_id and m.account_id == ^account_id
      ),
      []
    )
  end

  def multi(%__MODULE__{project_id: project_id, account_or_member_id: {:member, member_id}}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_assignment,
      from(m in ProjectMember,
        where: m.project_id == ^project_id and m.id == ^member_id
      ),
      []
    )
  end
end
