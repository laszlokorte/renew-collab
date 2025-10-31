defmodule RenewCollabProj.Queries.OwnProject do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:account_id, :project_id]

  def new(%{account_id: account_id, project_id: project_id}) do
    %__MODULE__{account_id: account_id, project_id: project_id}
  end

  def multi(%__MODULE__{account_id: account_id, project_id: project_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(p in Project,
        join: mem in assoc(p, :members),
        left_join: m in assoc(p, :members),
        where: mem.account_id == ^account_id and p.id == ^project_id,
        preload: [
          members: m
        ]
      )
    )
  end
end
