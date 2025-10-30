defmodule RenewCollabSim.Queries.SimulationNetInstanceById do
  alias RenewCollabSim.Entities.SimulationNetInstance
  import Ecto.Query

  defstruct [:net_instance_id]

  def new(%{net_instance_id: net_instance_id}) do
    %__MODULE__{net_instance_id: net_instance_id}
  end

  def multi(%__MODULE__{net_instance_id: net_instance_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(ins in SimulationNetInstance,
        join: sim in assoc(ins, :simulation),
        join: net in assoc(ins, :shadow_net),
        left_join: tokens in assoc(ins, :tokens),
        left_join: firings in assoc(ins, :firings),
        on: firings.timestep == sim.timestep,
        where: ins.id == ^net_instance_id,
        order_by: [asc: firings.timestep],
        preload: [tokens: tokens, firings: firings, shadow_net: net]
      )
    )
  end
end
