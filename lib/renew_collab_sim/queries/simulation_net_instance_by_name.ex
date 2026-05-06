defmodule RenewCollabSim.Queries.SimulationNetInstanceByName do
  alias RenewCollabSim.Entities.SimulationNetInstance
  alias RenewCollabSim.Entities.SimulationTransitionFiring
  import Ecto.Query

  defstruct [:simulation_id, :net_name, :integer_id]

  def new(%{simulation_id: simulation_id, net_name: net_name, integer_id: integer_id}) do
    %__MODULE__{simulation_id: simulation_id, net_name: net_name, integer_id: integer_id}
  end

  def multi(%__MODULE__{simulation_id: simulation_id, net_name: net_name, integer_id: integer_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :instance,
      from(ins in SimulationNetInstance,
        join: sim in assoc(ins, :simulation),
        join: net in assoc(ins, :shadow_net),
        where:
          ins.simulation_id == ^simulation_id and net.name == ^net_name and
            ins.integer_id == ^integer_id,
        preload: [shadow_net: net]
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{instance: instance} ->
      {:ok,
       instance
       |> repo.preload([
         {:firings,
          from(f in SimulationTransitionFiring,
            where: f.timestep == ^instance.simulation.timestep
          )},
         :tokens
       ])}
    end)
  end
end
