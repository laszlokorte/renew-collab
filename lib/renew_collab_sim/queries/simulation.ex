defmodule RenewCollabSim.Queries.Simulation do
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:simulation_id, :detailed]

  def new(%{simulation_id: id, detailed: detailed}) do
    %__MODULE__{simulation_id: id, detailed: detailed}
  end

  def new(%{simulation_id: id}) do
    %__MODULE__{simulation_id: id, detailed: false}
  end

  def multi(%__MODULE__{simulation_id: id, detailed: detailed}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :sim,
      from(s in Simulation,
        join: sns in assoc(s, :shadow_net_system),
        where: s.id == ^id
      )
    )
    |> Ecto.Multi.run(:result, fn
      _, %{sim: nil} ->
        {:ok, nil}

      repo, %{sim: sim} ->
        if detailed do
          sim
          |> repo.preload(:log_entries)
          |> repo.preload(net_instances: [:firings, :tokens, :shadow_net])
          |> repo.preload(shadow_net_system: [:nets])
        else
          sim
          |> repo.preload(net_instances: [:tokens, :shadow_net])
          |> repo.preload(shadow_net_system: [:nets])
        end
        |> then(&{:ok, &1})
    end)
  end
end
