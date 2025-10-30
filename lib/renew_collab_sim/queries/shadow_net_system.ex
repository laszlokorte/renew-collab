defmodule RenewCollabSim.Queries.ShadowNetSystem do
  alias RenewCollabSim.Entities.ShadowNetSystem
  import Ecto.Query

  defstruct [:shadow_net_system_id]

  def new(%{shadow_net_system_id: id}) do
    %__MODULE__{shadow_net_system_id: id}
  end

  def multi(%__MODULE__{shadow_net_system_id: id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(s in ShadowNetSystem,
        left_join: nets in assoc(s, :nets),
        left_join: sims in assoc(s, :simulations),
        where: s.id == ^id,
        order_by: [desc: s.inserted_at, asc: sims.inserted_at],
        preload: [nets: nets, simulations: sims]
      )
    )
  end
end
