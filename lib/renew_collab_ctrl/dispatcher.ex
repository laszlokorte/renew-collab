defmodule RenewCollabCtrl.Dispatcher do
  alias RenewCollabCtrl.Notification
  alias RenewCollabCtrl.WriteAccess
  alias RenewCollabCtrl.Action
  alias RenewCollabCtrl.CacheServer
  alias RenewCollabCtrl.CacheConfig

  def perform_as(action, account) do
    if WriteAccess.can(account, action) do
      {:ok, project_before} =
        associated_project(action)

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
          notify(project_before, action, :ok)
          res

        res = {:ok, result} ->
          notify(project_before, action, result)
          res

        res ->
          res
      end
    else
      raise "Access denied: #{inspect(action)}"
      :access_denied
    end
  end

  defp notify(project, action, result) do
    for {channel, message} <- Notification.notifications_for(project, action, result) do
      Phoenix.PubSub.broadcast(RenewCollab.PubSub, channel, message)
    end
  end

  defp evict_cache(tags) do
    CacheServer.delete_tags(tags)
  end

  defp associated_project(%{project_id: project_id}) do
    RenewCollabProj.Queries.ProjectWithMembers.new(%{project_id: project_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  defp associated_project(%{document_id: document_id}) do
    RenewCollabProj.Queries.ProjectWithMembers.new(%{document_id: document_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  defp associated_project(%{simulation_id: simulation_id}) do
    RenewCollabProj.Queries.ProjectWithMembers.new(%{simulation_id: simulation_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  defp associated_project(%{shadow_net_system_id: shadow_net_system_id}) do
    RenewCollabProj.Queries.ProjectWithMembers.new(%{shadow_net_system_id: shadow_net_system_id})
    |> RenewCollabProj.ProjectFetcher.fetch()
  end

  defp associated_project(_) do
    {:ok, nil}
  end
end
