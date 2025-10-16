defmodule RenewCollabCtrl.Dispatcher do
  alias RenewCollabCtrl.Action
  alias RenewCollabCtrl.CacheServer
  alias RenewCollabCtrl.CacheConfig
  alias RenewCollabCtrl.ReadAccess

  def perform_as(action, account) do
    if ReadAccess.can(account, action) do
      Action.do_perform(action)
      |> case do
        {:error, :not_implemented} ->
          raise "Command not implemented: #{inspect(action)}"

        res = :ok ->
          CacheConfig.tags_for_action(action, :ok)
          |> evict_cache()

          res

        res = {:ok, result} ->
          CacheConfig.tags_for_action(action, result)
          |> evict_cache()

          res

        res = {:error, _e} ->
          res
      end
    end
  end

  defp evict_cache(tags) do
    CacheServer.delete_tags(tags)
  end
end
