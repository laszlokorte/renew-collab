defmodule RenewCollabProj.Commands.RemoveProjectMember do
  alias RenewCollabProj.Entities.ProjectMember
  import Ecto.Query

  defstruct [:project_id, :account_id]

  def new(%{project_id: project_id, account_id: account_id}) do
    %__MODULE__{project_id: project_id, account_id: account_id}
  end

  def multi(%__MODULE__{project_id: project_id, account_id: account_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_assignment,
      from(a in ProjectMember,
        where: a.project_id == ^project_id and a.account_id == ^account_id
      ),
      []
    )
  end
end
