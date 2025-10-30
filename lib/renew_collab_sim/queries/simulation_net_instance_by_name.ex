defmodule RenewCollabSim.Queries.SimulationNetInstanceByName do
  alias RenewCollabSim.Entites.SimulationNetInstance
  import Ecto.Query

  defstruct [:simulation_id, :net_name, :integer_id]

  def new(%{simulation_id: simulation_id, net_name: net_name, integer_id: integer_id}) do
    %__MODULE__{simulation_id: simulation_id, net_name: net_name, integer_id: integer_id}
  end

  def multi(%__MODULE__{simulation_id: simulation_id, net_name: net_name, integer_id: integer_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(ins in SimulationNetInstance,
        join: sim in assoc(ins, :simulation),
        join: net in assoc(ins, :shadow_net),
        left_join: tokens in assoc(ins, :tokens),
        left_join: firings in assoc(ins, :firings),
        on: firings.timestep == sim.timestep,
        where:
          ins.simulation_id == ^simulation_id and net.name == ^net_name and
            ins.integer_id == ^integer_id,
        order_by: [asc: firings.timestep],
        preload: [tokens: tokens, firings: firings, shadow_net: net]
      )
    )
  end
end
