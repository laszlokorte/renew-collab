defmodule RenewCollabWeb.ProjectController do
  use RenewCollabWeb, :controller

  alias RenewCollabProj.Projects

  action_fallback(RenewCollabWeb.FallbackController)

  def index(conn, _params) do
    projects = Projects.list_own_projects(own_account(conn))
    render(conn, :index, projects: projects)
  end

  def show(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :show, project: project)
  end

  def members(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :members, project: project)
  end

  def documents(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :documents, project: project)
  end

  def simulations(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :simulations, project: project)
  end

  def export(conn, %{"id" => project_id} = params) do
    project = Projects.find_own_project(own_account(conn), project_id)

    conn
    |> put_resp_header(
      "content-disposition",
      "#{if(Map.has_key?(params, "inline"), do: "inline", else: "attachment")}; filename=\"#{project.name}.zip\""
    )
    |> put_resp_header(
      "content-type",
      "text/plain+renew"
    )
    |> text("Foo")

    # TODO: Zip all documents and ssns
  end

  defp own_account(%{assigns: %{current_account: current_account}}) do
    current_account
  end

  defp own_account(_) do
    nil
  end
end
