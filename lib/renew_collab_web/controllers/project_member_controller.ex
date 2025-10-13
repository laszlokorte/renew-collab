defmodule RenewCollabWeb.ProjectMemberController do
  use RenewCollabWeb, :controller

  def index(conn, %{"project_id" => project_id}) do
    render(conn, :index,
      project_id: project_id,
      simulations:
        RenewCollabSim.Simulator.list_simulations(
          RenewCollabProj.Projects.list_project_simulations(project_id)
        )
    )
  end

  def create(conn, params = %{"project_id" => project_id, "email" => email}) do
  end
end
