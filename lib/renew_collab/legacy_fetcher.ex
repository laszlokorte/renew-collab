defmodule RenewCollab.LegacyFetcher do
  alias RenewCollab.Repo

  def fetch(%{__struct__: module} = query, ttl \\ @default_ttl) do
    apply(module, :multi, [query])
    |> Repo.transaction()
    |> case do
      {:ok, %{result: result}} -> result
    end
  end
end
