defmodule RenewCollabProj.Queries.OwnProjects do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:account_id]

  def new(%{account_id: account_id}) do
    %__MODULE__{account_id: account_id}
  end

  def multi(%__MODULE__{account_id: account_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :result,
      from(p in Project,
        join: mem in assoc(p, :members),
        where: mem.account_id == ^account_id,
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
