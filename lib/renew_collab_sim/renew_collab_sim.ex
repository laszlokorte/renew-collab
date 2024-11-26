defmodule RenewCollabSim.Simulator do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollabSim.Entites.SimulationLogEntry
  alias RenewCollabSim.Entites.SimulationNetInstance
  alias RenewCollabSim.Entites.ShadowNetSystem
  alias RenewCollabSim.Entites.Simulation
  alias RenewCollab.Repo

  def list_shadow_net_systems do
    Repo.all(
      from(s in ShadowNetSystem,
        join: nets in assoc(s, :nets),
        order_by: [desc: s.inserted_at],
        preload: [nets: nets]
      )
    )
  end

  def find_shadow_net_system(id) do
    Repo.one!(
      from(s in ShadowNetSystem,
        join: nets in assoc(s, :nets),
        left_join: sims in assoc(s, :simulations),
        where: s.id == ^id,
        order_by: [desc: s.inserted_at, asc: sims.inserted_at],
        preload: [nets: nets, simulations: sims]
      )
    )
  end

  def find_simulation(id) do
    Repo.one!(
      from(s in Simulation,
        left_join: logs in assoc(s, :log_entries),
        join: sns in assoc(s, :shadow_net_system),
        join: nets in assoc(sns, :nets),
        left_join: ins in assoc(s, :net_instances),
        left_join: tokens in assoc(ins, :tokens),
        where: s.id == ^id,
        order_by: [asc: logs.inserted_at, asc: fragment("?.rowid", logs)],
        preload: [
          log_entries: logs,
          shadow_net_system: {sns, [nets: nets]},
          net_instances: {ins, [tokens: tokens]}
        ]
      )
    )
  end

  def clear_log(id) do
    Repo.delete_all(
      from(l in SimulationLogEntry,
        where: l.simulation_id == ^id
      )
    )
  end

  def clear_instances(id) do
    Repo.delete_all(
      from(l in SimulationNetInstance,
        where: l.simulation_id == ^id
      )
    )
  end

  def delete_shadow_net_system(id) do
    Repo.delete(find_shadow_net_system(id))
  end

  def delete_simulation(id) do
    Repo.delete(find_simulation(id))
  end
end
