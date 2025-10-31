defmodule RenewCollabProj.ProjectCommander do
  alias RenewCollabProj.Repo

  def run_project_command(command)

  def run_project_command(command) do
    spawn(fn ->
      run_project_command_sync(command)
    end)
  end

  def run_project_command_sync(%{__struct__: module} = command) do
    apply(module, :multi, [command])
    |> run_project_transaction()
  end

  defp run_project_transaction(multi) do
    Repo.transact(multi)
  end
end
