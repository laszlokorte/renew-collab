defmodule RenewCollab.Fetcher do
  alias RenewCollab.Repo

  @default_ttl 600

  def fetch(%{__struct__: module} = query, ttl \\ @default_ttl) do
    RenewCollab.SimpleCache.cache(
      {:query, query},
      fn ->
        apply(module, :multi, [query])
        |> Repo.transaction()
        |> case do
          {:ok, %{result: result}} -> result
        end
      end,
      apply(module, :tags, [query]),
      ttl
    )
  end
end
