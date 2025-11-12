defmodule RenewCollabProj.Queries.CheckOwnership do
  alias RenewCollabProj.Entities.ProjectMember
  import Ecto.Query
  defstruct [:account_or_member, :project_id]

  def new(%{account_or_member: account_or_member, project_id: project_id}) do
    %__MODULE__{account_or_member: account_or_member, project_id: project_id}
  end

  def multi(%__MODULE__{account_or_member: account_or_member, project_id: proj_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      account_or_member
      |> case do
        {:account, account_id} ->
          from(m in ProjectMember,
            where: m.account_id == ^account_id and m.project_id == ^proj_id and m.role == :owner,
            select: count(m.account_id) > 0,
            limit: 1
          )

        {:member, member_id} ->
          from(m in ProjectMember,
            where: m.id == ^member_id and m.project_id == ^proj_id and m.role == :owner,
            select: count(m.account_id) > 0,
            limit: 1
          )
      end
    )
  end
end
