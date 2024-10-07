defmodule RenewCollab.Commander do
  alias RenewCollab.Versioning
  alias RenewCollab.Repo

  def run_document_command(command, snapshot \\ true)

  def run_document_command(%{__struct__: module} = command, snapshot) do
    apply(module, :multi, [command])
    |> then(&if(snapshot, do: Ecto.Multi.append(&1, Versioning.snapshot_multi()), else: &1))
    |> run_document_transaction()
  end

  defp run_document_transaction(multi) do
    Repo.transaction(multi)
    |> case do
      {:ok, values} ->
        with %{document_id: document_id} <- values do
          RenewCollab.SimpleCache.delete({:document, document_id})
          RenewCollab.SimpleCache.delete({:undo_redo, document_id})
          RenewCollab.SimpleCache.delete({:versions, document_id})
          RenewCollab.SimpleCache.delete({:hierarchy_missing, document_id})
          RenewCollab.SimpleCache.delete({:hierarchy_invalids, document_id})
          RenewCollab.SimpleCache.delete(:all_documents)
          RenewCollab.SimpleCache.delete(:all_documents)
          RenewCollab.SimpleCache.delete(:all_documents)
          RenewCollab.SimpleCache.delete({:document, document_id})
          RenewCollab.SimpleCache.delete({:undo_redo, document_id})
          RenewCollab.SimpleCache.delete({:versions, document_id})
          RenewCollab.SimpleCache.delete({:hierarchy_missing, document_id})
          RenewCollab.SimpleCache.delete({:hierarchy_invalids, document_id})
          RenewCollab.SimpleCache.delete(:all_documents)

          Phoenix.PubSub.broadcast(
            RenewCollab.PubSub,
            "document:#{document_id}",
            {:document_changed, document_id}
          )

          RenewCollabWeb.Endpoint.broadcast!(
            "documents",
            "documents:new",
            {"document:new", document_id}
          )

          RenewCollabWeb.Endpoint.broadcast!(
            "documents",
            "document:renamed",
            %{"id" => document_id}
          )

          RenewCollabWeb.Endpoint.broadcast!(
            "documents",
            "document:deleted",
            %{"id" => document_id}
          )

          {:ok, values}
        end
    end
  end
end
