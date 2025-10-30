defmodule RenewCollabSim.Queries.Simulation do
  alias RenewCollabSim.Entities.SimulationLogEntry
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
        left_join: nets in assoc(sns, :nets),
        left_join: ins in assoc(s, :net_instances),
        left_join: net in assoc(ins, :shadow_net),
        left_join: tokens in assoc(ins, :tokens),
        where: s.id == ^id,
        preload: [
          shadow_net_system: {sns, [nets: nets]},
          net_instances: {ins, [tokens: tokens, shadow_net: net]}
        ]
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{sim: sim} ->
      if detailed do
        sim
        |> repo.preload(:log_entries)
        |> repo.preload(net_instances: :firings)
      else
        sim
      end
    end)
  end
end
