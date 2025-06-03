defmodule RenewCollabProj.Projects do
  @moduledoc """
  The Renew context.
  """

  alias RenewCollabProj.Entites.Project
  alias RenewCollabProj.Repo

  import Ecto.Query, warn: false

  def create_project(params) do
    %Project{} |> Project.changeset(params) |> Repo.insert()
  end

  def list_all_projects() do
    Repo.all(
      from(p in Project,
        left_join: m in assoc(p, :members),
        left_join: d in assoc(p, :documents),
        left_join: s in assoc(p, :simulations),
        order_by: [asc: :inserted_at],
        preload: [
          members: m,
          documents: d,
          simulations: s
        ]
      )
    )
  end

  def find_project(id) do
    Repo.one(
      from(
        p in Project,
        left_join: m in assoc(p, :members),
        left_join: d in assoc(p, :documents),
        left_join: s in assoc(p, :simulations),
        where: p.id == ^id,
        order_by: [asc: :inserted_at],
        preload: [
          members: m,
          documents: d,
          simulations: s
        ]
      )
    )
    |> RenewCollab.Repo.preload(documents: [:document])
    |> RenewCollabAuth.Repo.preload(members: [:account])
    |> RenewCollabSim.Repo.preload(simulations: [:simulation])
  end

  def delete_project(id) do
    Repo.delete_all(from(p in Project, where: p.id == ^id))
  end
end
