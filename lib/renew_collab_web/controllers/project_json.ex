defmodule RenewCollabWeb.ProjectJSON do
  alias RenewCollabProj.Entites.Project

  use RenewCollabWeb, :verified_routes

  @doc """
  Renders a list of projects.
  """
  def index(%{projects: projects}) do
    %{
      href: url(~p"/api/projects"),
      content: index_content(%{projects: projects})
    }
  end

  def show(%{project: project}) do
    detail_data(project)
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

  defp detail_data(%Project{} = project) do
    %{
      # id: document.id,
      href: url(~p"/api/projects/#{project}"),
      topic: "redux_project:#{project.id}",
      id: project.id,
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
      content: show_content(project)
    }
  end

  def show_content(%Project{} = project) do
    %{
      name: project.name
    }
  end
end
