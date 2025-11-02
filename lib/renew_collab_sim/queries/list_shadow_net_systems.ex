defmodule RenewCollabSim.Queries.ListShadowNetSystems do
  alias RenewCollabSim.Entities.ShadowNetSystem
  alias RenewCollabSim.Entities.Simulation
  import Ecto.Query

  defstruct [:shadow_net_system_ids]

  def new(%{shadow_net_system_ids: ids}) do
    %__MODULE__{shadow_net_system_ids: ids}
  end

  def multi(%__MODULE__{shadow_net_system_ids: :all}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(s in ShadowNetSystem,
        as: :sns,
        left_join: nets in assoc(s, :nets),
        left_join: sims in assoc(s, :simulations),
        order_by: [desc: s.inserted_at],
        preload: [nets: nets],
        select: map(s, ^ShadowNetSystem.__schema__(:fields)),
        select_merge: %{
          simulation_count:
            subquery(
              from(sims in Simulation,
                where: sims.shadow_net_system_id == parent_as(:sns).id,
                select: count(sims.id)
              )
            )
        }
      )
    )
  end

  def multi(%__MODULE__{shadow_net_system_ids: ids}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(s in ShadowNetSystem,
        as: :sns,
        left_join: nets in assoc(s, :nets),
        left_join: sims in assoc(s, :simulations),
        where: s.id in ^ids,
        order_by: [desc: s.inserted_at],
        preload: [nets: nets],
        select: map(s, ^ShadowNetSystem.__schema__(:fields)),
        select_merge: %{
          simulation_count:
            subquery(
              from(sims in Simulation,
                where: sims.shadow_net_system_id == parent_as(:sns).id,
                select: count(sims.id)
              )
            )
        }
      )
    )
  end
end
