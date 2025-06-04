defmodule RenewCollabWeb.ProjectController do
  use RenewCollabWeb, :controller

  alias RenewCollabProj.Projects
  alias RenewCollabProj.Entities.Project

  action_fallback(RenewCollabWeb.FallbackController)

  def index(conn, _params) do
    projects = Projects.list_own_projects(own_account(conn))
    render(conn, :index, projects: projects)
  end

  def show(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :show, project: project)
  end

  defp own_account(%{assigns: %{current_account: %{id: account_id}}}) do
    account_id
  end

  defp own_account(_) do
    nil
  end
end
