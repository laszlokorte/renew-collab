defmodule RenewCollabProj.ProjectFetcher do
  alias RenewCollabProj.Repo

  def fetch(%{__struct__: module} = query) do
    apply(module, :multi, [query])
    |> Repo.transact()
    |> case do
      {:ok, %{result: result}} -> {:ok, result}
      o -> o
    end
  end
end
