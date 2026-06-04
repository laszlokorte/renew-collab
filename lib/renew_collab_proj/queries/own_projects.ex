defmodule RenewCollabProj.Queries.OwnProjects do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:account_id]

  def new(%{account_id: account_id}) do
    %__MODULE__{account_id: account_id}
  end

  def multi(%__MODULE__{account_id: account_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :projects,
      from(p in Project,
        join: mem in assoc(p, :members),
        where: mem.account_id == ^account_id,
        order_by: [desc: :inserted_at]
      )
    )
    |> Ecto.Multi.run(:result, fn _repo, %{projects: projects} ->
      {:ok, projects}
    end)
  end
end
