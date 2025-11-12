defmodule RenewCollabAuth.AuthCommander do
  alias RenewCollabAuth.Repo

  def run_auth_command_sync(%{__struct__: module} = command) do
    apply(module, :multi, [command])
    |> run_auth_transaction()
  end

  defp run_auth_transaction(multi) do
    Repo.transact(multi)
  end
end
