defmodule RenewCollabProj.Queries.OwnProjects do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:account_id]

  def new(%{account_id: account_id}) do
    %__MODULE__{account_id: account_id}
  end

  def multi(%__MODULE__{account_id: account_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(p in Project,
        join: mem in assoc(p, :members),
        where: mem.account_id == ^account_id
      )
    )
  end
end
