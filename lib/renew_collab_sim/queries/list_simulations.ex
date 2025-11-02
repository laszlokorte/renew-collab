defmodule RenewCollabSim.Queries.ListSimulations do
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:simulation_ids]

  def new(%{simulation_ids: ids}) do
    %__MODULE__{simulation_ids: ids}
  end

  def multi(%__MODULE__{simulation_ids: :all}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(s in Simulation,
        inner_join: sns in assoc(s, :shadow_net_system),
        order_by: [desc: s.inserted_at],
        preload: [
          shadow_net_system: sns
        ]
      )
    )
  end

  def multi(%__MODULE__{simulation_ids: ids}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(s in Simulation,
        where: s.id in ^ids,
        inner_join: sns in assoc(s, :shadow_net_system),
        order_by: [desc: s.inserted_at],
        preload: [
          shadow_net_system: sns
        ]
      )
    )
  end
end
