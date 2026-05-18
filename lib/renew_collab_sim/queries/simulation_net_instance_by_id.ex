defmodule RenewCollabSim.Queries.SimulationNetInstanceById do
  alias RenewCollabSim.Entities.SimulationNetInstance
  alias RenewCollabSim.Entities.SimulationTransitionFiring
  import Ecto.Query

  defstruct [:net_instance_id]

  def new(%{net_instance_id: net_instance_id}) do
    %__MODULE__{net_instance_id: net_instance_id}
  end

  def multi(%__MODULE__{net_instance_id: net_instance_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :instance,
      from(ins in SimulationNetInstance,
        join: sim in assoc(ins, :simulation),
        join: net in assoc(ins, :shadow_net),
        where: ins.id == ^net_instance_id,
        preload: [shadow_net: net, simulation: sim]
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
