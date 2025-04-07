defmodule RenewCollab.Commander do
  alias RenewCollab.Versioning
  alias RenewCollab.Repo

  def run_document_command(command, snapshot \\ true)

  def run_document_command(command, snapshot) do
    spawn(fn ->
      run_document_command_sync(command, snapshot)
    end)
  end

  def run_document_command_sync(command, snapshot \\ true)

  def run_document_command_sync(
        %{__struct__: module, document_id: document_id} = command,
        snapshot
      ) do
    auto_snapshot = apply(module, :auto_snapshot, [command])

    apply(module, :multi, [command])
    |> then(
      &if(auto_snapshot and snapshot,
        do: Ecto.Multi.append(&1, Versioning.snapshot_multi(document_id)),
        else: &1
      )
    )
    |> run_document_transaction(apply(module, :tags, [command]))
  end

  def run_document_command_sync(
        %{__struct__: module} = command,
        snapshot
      ) do
    auto_snapshot = apply(module, :auto_snapshot, [command])

    apply(module, :multi, [command])
    |> Ecto.Multi.merge(fn %{document_id: document_id} ->
      if(auto_snapshot and snapshot,
        do: Versioning.snapshot_multi(document_id),
        else: Ecto.Multi.new()
      )
    end)
    |> run_document_transaction(apply(module, :tags, [command]))
  end

  defp run_document_transaction(multi, tags) do
    Repo.transaction(multi)
    |> case do
      {:ok, values} ->
        values
        |> Enum.find_value(fn
          {:document_id, document_id} -> document_id
          {{_, :document_id}, document_id} -> document_id
          _ -> false
        end)
        |> case do
          document_id when is_binary(document_id) ->
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

          oo ->
            dbg(oo)
        end

      other ->
        other
    end
  end
end
