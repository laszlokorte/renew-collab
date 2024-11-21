defmodule RenewCollabSim.Simulator do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollabSim.Entites.ShadowNetSystem
  alias RenewCollab.Repo

  def list_shadow_net_systems do
    Repo.all(
      from(s in ShadowNetSystem,
        join: n in assoc(s, :nets),
        order_by: [desc: s.inserted_at],
        preload: [nets: n]
      )
    )
  end

  def find_shadow_net_system(id) do
    Repo.one(from(s in ShadowNetSystem, where: s.id == ^id))
  end

  def delete_shadow_net_system(id) do
    Repo.delete(find_shadow_net_system(id))
  end
end
