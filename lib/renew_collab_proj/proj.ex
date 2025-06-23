defmodule RenewCollabProj.Projects do
  @moduledoc """
  The Renew context.
  """

  alias RenewCollabProj.Entites.Project
  alias RenewCollabProj.Repo
  alias RenewCollabProj.Entites.ProjectMember
  alias RenewCollabProj.Entites.ProjectDocument
  alias RenewCollabProj.Entites.ProjectSimulation

  import Ecto.Query, warn: false

  def create_project(params) do
    %Project{} |> Project.creation_changeset(params) |> dbg |> Repo.insert() |> dbg
  end

  def count_projects() do
    Repo.one(from(p in Project, select: count(p.id)))
  end

  def list_all_projects() do
    Repo.all(
      from(p in Project,
        left_join: m in assoc(p, :members),
        left_join: o in assoc(p, :ownerships),
        left_join: d in assoc(p, :documents),
        left_join: s in assoc(p, :simulations),
        order_by: [desc: :inserted_at],
        preload: [
          ownerships: o,
          members: m,
          documents: d,
          simulations: s
        ]
      )
    )
  end

  def list_own_projects(nil), do: []

  def list_own_projects(account_id) do
    Repo.all(
      from(p in Project,
        left_join: m in assoc(p, :members),
        left_join: o in assoc(p, :ownerships),
        left_join: d in assoc(p, :documents),
        left_join: s in assoc(p, :simulations),
        inner_join: mm in assoc(p, :members),
        where: mm.account_id == ^account_id,
        order_by: [desc: :inserted_at],
        preload: [
          ownerships: o,
          members: m,
          documents: d,
          simulations: s
        ]
      )
    )
  end

  def find_own_project(account_id, project_id) do
    Repo.one(
      from(
        p in Project,
        left_join: m in assoc(p, :members),
        left_join: d in assoc(p, :documents),
        left_join: s in assoc(p, :simulations),
        inner_join: mm in assoc(p, :members),
        where: p.id == ^project_id,
        where: mm.account_id == ^account_id,
        order_by: [asc: m.inserted_at, asc: d.inserted_at, asc: s.inserted_at],
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

  def find_project(id) do
    Repo.one(
      from(
        p in Project,
        left_join: m in assoc(p, :members),
        left_join: d in assoc(p, :documents),
        left_join: s in assoc(p, :simulations),
        where: p.id == ^id,
        order_by: [asc: m.inserted_at, asc: d.inserted_at, asc: s.inserted_at],
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

  def find_documents() do
    from(d in RenewCollab.Document.Document)
    |> RenewCollab.Repo.all()
    |> Repo.preload(project_assignment: [])
  end

  def find_simulations() do
    from(s in RenewCollabSim.Entites.Simulation)
    |> RenewCollabSim.Repo.all()
    |> Repo.preload(project_assignment: [])
  end

  def find_accounts() do
    from(a in RenewCollabAuth.Entites.Account)
    |> RenewCollabAuth.Repo.all()
  end

  def add_member(%Project{id: project_id}, member) do
    %ProjectMember{
      project_id: project_id
    }
    |> ProjectMember.changeset(member)
    |> Repo.insert()
  end

  def add_document(%Project{id: project_id}, document) do
    %ProjectDocument{
      project_id: project_id
    }
    |> ProjectDocument.changeset(document)
    |> Repo.insert()
  end

  def add_simulation(%Project{id: project_id}, simulation) do
    %ProjectSimulation{
      project_id: project_id
    }
    |> ProjectSimulation.changeset(simulation)
    |> Repo.insert()
  end

  def remove_member(%Project{id: project_id}, member_id) do
    from(m in ProjectMember, where: m.id == ^member_id and m.project_id == ^project_id)
    |> Repo.delete_all()
  end

  def remove_document(%Project{id: project_id}, document_id) do
    from(m in ProjectDocument, where: m.id == ^document_id and m.project_id == ^project_id)
    |> Repo.delete_all()
  end

  def remove_simulation(%Project{id: project_id}, simulation_id) do
    from(m in ProjectSimulation, where: m.id == ^simulation_id and m.project_id == ^project_id)
    |> Repo.delete_all()
  end

  def update_project(%Project{} = project, params) do
    project |> Project.changeset(params) |> Repo.update()
  end

  def member_roles(), do: RenewCollabProj.Entites.ProjectMember.roles()
end
