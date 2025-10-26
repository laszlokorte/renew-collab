defmodule RenewCollabProj.ProjectFetcher do
  alias RenewCollabProj.Repo

  def run_project_command(command)

  def run_project_command(command) do
    spawn(fn ->
      run_project_command_sync(command)
    end)
  end

  def run_project_command_sync(%{__struct__: module} = command) do
    apply(module, :multi, [command])
    |> run_project_transaction(apply(module, :tags, [command]))
  end

  defp run_project_transaction(multi, tags) do
    Repo.transact(multi)
  end
end
