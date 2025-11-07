defmodule RenewCollabWeb.ProjectJSON do
  alias RenewCollabProj.Entities.Project

  use RenewCollabWeb, :verified_routes

  @doc """
  Renders a list of projects.
  """
  def index(%{projects: projects}) do
    %{
      href: url(~p"/api/projects"),
      topic: "my-projects",
      content: index_content(%{projects: projects})
    }
  end

  def show(%{project: project, members: members}) do
    detail_data(%{project: project, members: members})
  end

  def export(%{project: project}) do
    %{
      href: url(~p"/api/projects/#{project.id}/export"),
      project: %{
        href: url(~p"/api/projects/#{project}"),
        name: project.name,
        id: project.id
      }
    }
  end

  def projects(%{project: project}) do
    %{
      href: url(~p"/api/projects/#{project.id}/documents"),
      project: %{
        href: url(~p"/api/projects/#{project}"),
        name: project.name,
        id: project.id
      }
    }
  end

  def simulations(%{project: project}) do
    %{
      href: url(~p"/api/projects/#{project.id}/simulations"),
      project: %{
        href: url(~p"/api/projects/#{project}"),
        name: project.name,
        id: project.id
      }
    }
  end

  def members(%{project: project}) do
    %{
      href: url(~p"/api/projects/#{project.id}/members"),
      project: %{
        href: url(~p"/api/projects/#{project}"),
        name: project.name,
        id: project.id
      }
    }
  end

  def index_content(%{projects: projects}) do
    %{
      items: for(project <- projects, do: list_data(project))
    }
  end

  defp list_data(%Project{} = project) do
    %{
      # id: project.id,
      href: url(~p"/api/projects/#{project}"),
      name: project.name,
      id: project.id,
      links: %{
        export: %{
          method: "GET",
          href: url(~p"/api/projects/#{project.id}/export")
        }
      }
    }
  end

  defp detail_data(%{project: project, members: members}) do
    %{
      # id: document.id,
      href: url(~p"/api/projects/#{project}"),
      id: project.id,
      topic: "project:#{project.id}",
      links: %{
        documents: %{
          method: "GET",
          href: url(~p"/api/projects/#{project.id}/documents")
        },
        simulations: %{
          method: "GET",
          href: url(~p"/api/projects/#{project.id}/simulations")
        },
        members: %{
          method: "GET",
          href: url(~p"/api/projects/#{project.id}/members")
        },
        export: %{
          method: "GET",
          href: url(~p"/api/projects/#{project.id}/export")
        }
      },
      content: show_content(%{project: project, members: members})
    }
  end

  def show_content(%{project: project, members: members}) do
    %{
      name: project.name,
      invitations: %{
        items:
          for i <- project.invitations do
            %{id: i.id, email: i.email, role: i.role}
          end
      },
      members: %{
        items:
          for m <- members do
            %{id: m.id, email: m.account.email, role: m.role}
          end
      }
    }
  end
end
