defmodule RenewCollabSim.SimulationFetcher do
  alias RenewCollabSim.Repo

  def fetch(%{__struct__: module} = query) do
    apply(module, :multi, [query])
    |> Repo.transact()
    |> case do
      {:ok, %{result: result}} -> {:ok, result}
    end
  end
end
