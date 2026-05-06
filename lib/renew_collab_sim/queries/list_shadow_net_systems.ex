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
      :sns,
      from(s in ShadowNetSystem,
        as: :sns,
        order_by: [desc: s.inserted_at],
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
    |> Ecto.Multi.run(:result, fn repo, %{sns: sns} ->
      {:ok,
       struct(ShadowNetSystem, sns)
       |> repo.preload([
         :nets
       ])}
    end)
  end

  def multi(%__MODULE__{shadow_net_system_ids: ids}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :sns,
      from(s in ShadowNetSystem,
        as: :sns,
        where: s.id in ^ids,
        order_by: [desc: s.inserted_at],
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
    |> Ecto.Multi.run(:result, fn repo, %{sns: sns} ->
      {:ok,
       sns
       |> Enum.map(&struct(ShadowNetSystem, &1))
       |> repo.preload([
         :nets
       ])}
    end)
  end
end
