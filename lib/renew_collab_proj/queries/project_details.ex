defmodule RenewCollabProj.Queries.ProjectDetails do
  alias RenewCollabProj.Entities.Project
  import Ecto.Query

  defstruct [:project_id]

  def new(%{project_id: project_id}) do
    %__MODULE__{project_id: project_id}
  end

  def multi(%__MODULE__{project_id: project_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(
        p in Project,
        left_join: m in assoc(p, :members),
        left_join: d in assoc(p, :documents),
        left_join: sns in assoc(p, :shadow_net_systems),
        left_join: s in assoc(p, :simulations),
        left_join: i in assoc(p, :invitations),
        where: p.id == ^project_id,
        order_by: [asc: m.inserted_at, asc: d.inserted_at, asc: i.inserted_at, asc: s.inserted_at],
        preload: [
          members: m,
          documents: d,
          shadow_net_systems: sns,
          simulations: s,
          invitations: i
        ]
      )
    )
  end
end
