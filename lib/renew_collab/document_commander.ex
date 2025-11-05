defmodule RenewCollab.DocumentCommander do
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
    |> run_document_transaction()
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
    |> run_document_transaction()
  end

  defp run_document_transaction(multi) do
    Repo.transact(multi)
  end
end
