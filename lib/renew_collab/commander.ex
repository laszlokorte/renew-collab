defmodule RenewCollab.Commander do
  alias RenewCollab.Versioning
  alias RenewCollab.Repo

  def run_document_command(command, snapshot \\ true)

  def run_document_command(%{__struct__: module} = command, snapshot) do
    spawn(fn ->
      auto_snapshot = apply(module, :auto_snapshot, [command])

      apply(module, :multi, [command])
      |> then(
        &if(auto_snapshot and snapshot,
          do: Ecto.Multi.append(&1, Versioning.snapshot_multi()),
          else: &1
        )
      )
      |> run_document_transaction(apply(module, :tags, [command]))
    end)
  end

  defp run_document_transaction(multi, tags) do
    Repo.transaction(multi)
    |> case do
      {:ok, values} ->
        with %{document_id: document_id} <- values do
          RenewCollab.SimpleCache.delete_tags([{:document_versions, document_id} | tags])

          for tag <- tags do
            case tag do
              :document_collection ->
                Phoenix.PubSub.broadcast(
                  RenewCollab.PubSub,
                  "documents",
                  :any
                )

              {:document_content, ^document_id} ->
                Phoenix.PubSub.broadcast(
                  RenewCollab.PubSub,
                  "document:#{document_id}",
                  {:document_changed, document_id}
                )

              {:document_versions, ^document_id} ->
                Phoenix.PubSub.broadcast(
                  RenewCollab.PubSub,
                  "document:#{document_id}",
                  {:versions_changed, document_id}
                )

              _ ->
                nil
            end
          end

          {:ok, values}
        end
    end
  end
end
