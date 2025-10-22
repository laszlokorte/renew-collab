defmodule RenewCollabCtrl.Fetcher do
  alias RenewCollabCtrl.View
  alias RenewCollabCtrl.CacheConfig
  alias RenewCollabCtrl.CacheServer
  alias RenewCollabCtrl.ReadAccess

  def fetch_as(view, account) do
    if ReadAccess.can(account, view) do
      cache_key = CacheConfig.key_for_view(account, view)

      cached_or_do(
        cache_key,
        fn ->
          View.do_fetch(account, view)
          |> case do
            {:error, :not_implemented} -> raise "View not implemented: #{inspect(view)}"
            {:ok, value} -> value
            {:error, e} -> raise "Fetch error: #{inspect(e)}"
          end
        end,
        CacheConfig.tags_for_view(account, view),
        CacheConfig.ttl_for_view(view)
      )
    else
      raise "Access denied: #{inspect(view)}"
      :access_denied
    end
  end

  def cached_or_do(key, fun, tags, lifetime \\ :infinity)

  def cached_or_do(nil, fun, _, _) do
    fun.()
  end

  def cached_or_do(key, fun, tags, lifetime)
      when is_function(fun) and
             (lifetime == :infinity or (is_integer(lifetime) and lifetime >= 0)) do
    case CacheServer.get(key, lifetime) do
      {:ok, value} ->
        {:ok, value}

      :error ->
        fun.()
        |> case do
          res = {:ok, result} ->
            CacheServer.put(key, result, tags)

            res

          err = {:error, _} ->
            err
        end
    end
  end
end
