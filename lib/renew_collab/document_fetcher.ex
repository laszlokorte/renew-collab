defmodule RenewCollab.DocumentFetcher do
  alias RenewCollab.Repo

  def fetch(%{__struct__: module} = query) do
    apply(module, :multi, [query])
    |> Repo.transact()
    |> case do
      {:ok, %{result: result}} -> result
    end
  end
end
