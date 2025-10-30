defmodule RenewCollabSim.SimulationCommander do
  alias RenewCollabSim.Repo

  def run_simulation_command(command)

  def run_simulation_command(command) do
    spawn(fn ->
      run_simulation_command_sync(command)
    end)
  end

  def run_simulation_command_sync(%{__struct__: module} = command) do
    apply(module, :multi, [command])
    |> run_simulation_transaction(apply(module, :tags, [command]))
  end

  defp run_simulation_transaction(multi, _tags) do
    Repo.transact(multi)
  end
end
