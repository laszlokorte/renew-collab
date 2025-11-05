defmodule RenewCollabCtrl.Dispatcher do
  alias RenewCollabCtrl.Notification
  alias RenewCollabCtrl.WriteAccess
  alias RenewCollabCtrl.Action
  alias RenewCollabCtrl.CacheServer
  alias RenewCollabCtrl.CacheConfig

  def perform_as(action, account) do
    if WriteAccess.can(account, action) do
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
      |> case do
        res = :ok ->
          notify(action, res)
          res

        res = {:ok, result} ->
          notify(action, res)
          res

        res ->
          res
      end
    else
      raise "Access denied: #{inspect(action)}"
      :access_denied
    end
  end

  defp notify(action, result) do
    for {channel, message} <- Notification.notifications_for(action, result) do
      Phoenix.PubSub.broadcast(RenewCollab.PubSub, channel, message)
    end
  end

  defp evict_cache(tags) do
    CacheServer.delete_tags(tags)
  end
end
