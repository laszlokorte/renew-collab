defmodule RenewCollabCtrl.Fetcher do
  alias RenewCollabCtrl.Subscription
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
            {:ok, value} -> value
            {:error, e} -> raise "Fetch error: #{inspect(e)}"
          end
        end,
        CacheConfig.tags_for_view(account, view),
        CacheConfig.ttl_for_view(view)
      )
    else
      {:error, :access}
    end
  end

  def subscribe(view) do
    Subscription.channel_for(view)
    |> case do
      channel when is_binary(channel) ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, channel)

      nil ->
        nil
    end
  end

  def fetch_and_subscribe(view, account) do
    result = fetch_as(view, account)

    subscribe(view)

    result
  end

  def cached_or_do(key, fun, tags, lifetime \\ :infinity)

  def cached_or_do(nil, fun, _, _) do
    fun.()
  end

  def cached_or_do(key, fun, tags, lifetime)
      when is_function(fun) and
             (lifetime == :infinity or (is_integer(lifetime) and lifetime >= 0)) do
    case CacheServer.get(key, lifetime) do
      {:ok, result} ->
        result

      :error ->
        result = fun.()
        CacheServer.put(key, result, tags)
        result
    end
  end
end
