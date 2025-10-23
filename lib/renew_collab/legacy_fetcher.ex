defmodule RenewCollab.LegacyFetcher do
  alias RenewCollab.Repo

  def fetch(%{__struct__: module} = query, _ttl) do
    apply(module, :multi, [query])
    |> Repo.transaction()
    |> case do
      {:ok, %{result: result}} -> result
    end
  end
end
