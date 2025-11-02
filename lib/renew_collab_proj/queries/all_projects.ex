defmodule RenewCollabProj.Queries.AllProjects do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(p in Project,
        left_join: m in assoc(p, :members),
        left_join: o in assoc(p, :ownerships),
        left_join: sns in assoc(p, :shadow_net_systems),
        left_join: d in assoc(p, :documents),
        left_join: s in assoc(p, :simulations),
        order_by: [desc: :inserted_at],
        preload: [
          ownerships: o,
          members: m,
          documents: d,
          shadow_net_systems: sns,
          simulations: s
        ]
      )
    )
  end
end
