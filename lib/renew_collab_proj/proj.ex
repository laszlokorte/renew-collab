defmodule RenewCollabProj.Projects do
  @moduledoc """
  The Renew context.
  """

  alias RenewCollabProj.Entites.ProjectShadowNetSystem
  alias RenewCollabProj.Entites.Project
  alias RenewCollabProj.Repo
  alias RenewCollabProj.Entites.ProjectMember
  alias RenewCollabProj.Entites.ProjectDocument
  alias RenewCollabProj.Entites.ProjectSimulation

  import Ecto.Query, warn: false

  def create_project(account_id, params) do
    %Project{}
    |> Project.creation_changeset(
      params
      |> Map.put("ownerships", [
        %{
          "role" => "owner",
          "account_id" => account_id
        }
      ])
    )
    |> Repo.insert()
  end

  def count_projects() do
    Repo.one(from(p in Project, select: count(p.id)))
  end

  def list_all_projects() do
    Repo.all(
      from(p in Project,
        left_join: m in assoc(p, :members),
        left_join: o in assoc(p, :ownerships),
        left_join: ssn in assoc(p, :shadow_net_systems),
        left_join: d in assoc(p, :documents),
        left_join: s in assoc(p, :simulations),
        order_by: [desc: :inserted_at],
        preload: [
          ownerships: o,
          members: m,
          documents: d,
          shadow_net_systems: ssn,
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
        left_join: ssn in assoc(p, :shadow_net_systems),
        left_join: s in assoc(p, :simulations),
        inner_join: mm in assoc(p, :members),
        where: mm.account_id == ^account_id,
        order_by: [desc: :inserted_at],
        preload: [
          ownerships: o,
          members: m,
          documents: d,
          shadow_net_systems: ssn,
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
        left_join: ssn in assoc(p, :shadow_net_systems),
        left_join: s in assoc(p, :simulations),
        inner_join: mm in assoc(p, :members),
        where: p.id == ^project_id,
        where: mm.account_id == ^account_id,
        order_by: [asc: m.inserted_at, asc: d.inserted_at, asc: s.inserted_at],
        preload: [
          members: m,
          documents: d,
          shadow_net_systems: ssn,
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
        left_join: ssn in assoc(p, :shadow_net_systems),
        left_join: s in assoc(p, :simulations),
        where: p.id == ^id,
        order_by: [asc: m.inserted_at, asc: d.inserted_at, asc: s.inserted_at],
        preload: [
          members: m,
          documents: d,
          shadow_net_systems: ssn,
          simulations: s
        ]
      )
    )
    |> RenewCollab.Repo.preload(documents: [:document])
    |> RenewCollabAuth.Repo.preload(members: [:account])
    |> RenewCollabSim.Repo.preload(simulations: [:simulation])
    |> RenewCollabSim.Repo.preload(shadow_net_systems: [:shadow_net_system])
  end

  def delete_project(id) do
    Repo.delete_all(from(p in Project, where: p.id == ^id))
  end

  def find_documents() do
    from(d in RenewCollab.Document.Document)
    |> RenewCollab.Repo.all()
    |> Repo.preload(project_assignment: [])
  end

  def find_shadow_net_systems() do
    from(d in RenewCollabSim.Entites.ShadowNetSystem)
    |> RenewCollabSim.Repo.all()
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
    from(m in ProjectMember,
      where: m.id == ^member_id and m.project_id == ^project_id and m.role != :owner
    )
    |> Repo.delete_all()
  end

  def remove_document(%Project{id: project_id}, document_id) do
    from(m in ProjectDocument, where: m.id == ^document_id and m.project_id == ^project_id)
    |> Repo.delete_all()
  end

  def remove_shadow_net_system(%Project{id: project_id}, ssn_id) do
    from(m in ProjectShadowNetSystem, where: m.id == ^ssn_id and m.project_id == ^project_id)
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

  def member_roles(own_account_id, project) do
    from(m in ProjectMember,
      where: m.project_id == ^project.id and m.account_id == ^own_account_id,
      select: m.role
    )
    |> Repo.one()
    |> RenewCollabProj.Entites.ProjectMember.weaker_roles()
  end

  def can_remove(own_account_id, membership) do
    from(m in ProjectMember,
      where:
        m.project_id == ^membership.project_id and m.account_id == ^own_account_id and
          ^membership.account_id != ^own_account_id,
      select: m.role == :owner
    )
    |> Repo.one()
  end

  def can_rename(own_account_id, project) do
    from(m in ProjectMember,
      where: m.project_id == ^project.id and m.account_id == ^own_account_id,
      select: m.role == :owner
    )
    |> Repo.one()
  end

  def can_invite(own_account_id, project) do
    from(m in ProjectMember,
      where: m.project_id == ^project.id and m.account_id == ^own_account_id,
      select: m.role == :owner
    )
    |> Repo.one()
  end

  def can_delete(own_account_id, project) do
    from(m in ProjectMember,
      where: m.project_id == ^project.id and m.account_id == ^own_account_id,
      select: m.role == :owner
    )
    |> Repo.one()
  end

  def list_project_documents(project_id) do
    from(p in Project,
      left_join: docs in assoc(p, :documents),
      where: p.id == ^project_id,
      preload: [
        documents: docs
      ]
    )
    |> Repo.one()
  end

  def list_project_simulations(project_id) do
    from(p in Project,
      left_join: sims in assoc(p, :simulations),
      where: p.id == ^project_id,
      preload: [
        simulations: sims
      ]
    )
    |> Repo.one()
    |> RenewCollabSim.Repo.preload(simulations: [:simulation])
  end

  def list_project_shadow_net_systems(project_id) do
    from(p in Project,
      left_join: ssn in assoc(p, :shadow_net_systems),
      where: p.id == ^project_id,
      preload: [
        shadow_net_systems: ssn
      ]
    )
    |> Repo.one()
  end

  def attach_project_assignment(object) do
    object |> Repo.preload(project_assignment: [:project], project: [])
  end

  def assign_to_project(project, %RenewCollab.Document.Document{} = document) do
    %ProjectDocument{project_id: project.id}
    |> ProjectDocument.changeset(%{
      "document_id" => document.id
    })
    |> Repo.insert()
    |> case do
      _ ->
        {:ok, document}
    end
  end

  def assign_to_project(project, %RenewCollabSim.Entites.ShadowNetSystem{} = sns) do
    %ProjectShadowNetSystem{project_id: project.id}
    |> ProjectShadowNetSystem.changeset(%{
      "shadow_net_system_id" => sns.id
    })
    |> Repo.insert()
    |> case do
      _ ->
        {:ok, sns}
    end
  end

  def assign_to_project(project, %RenewCollabSim.Entites.Simulation{} = sim) do
    %ProjectSimulation{project_id: project.id}
    |> ProjectSimulation.changeset(%{
      "simulation_id" => sim.id
    })
    |> Repo.insert()
    |> case do
      _ ->
        {:ok, sim}
    end
  end

  def find_documents_project(document_id) do
    from(p in Project,
      join: docs in assoc(p, :documents),
      where: docs.document_id == ^document_id
    )
    |> Repo.one()
  end

  def find_shadow_net_systems_project(sns_id) do
    from(p in Project,
      join: sns in assoc(p, :shadow_net_systems),
      where: sns.shadow_net_system_id == ^sns_id
    )
    |> Repo.one()
    |> dbg
  end

  def delete_document(document_id) do
    result =
      from(p in Project,
        join: docs in assoc(p, :documents),
        where: docs.document_id == ^document_id
      )
      |> Repo.one()

    from(d in ProjectDocument, where: d.document_id == ^document_id) |> Repo.delete_all([])

    result
  end
end
