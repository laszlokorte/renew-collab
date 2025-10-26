defmodule RenewCollabWeb.ProjectMemberController do
  use RenewCollabWeb, :controller

  def index(conn, %{"project_id" => _project_id}) do
    render(conn, :index)
  end

  def create(conn, %{"project_id" => _project_id, "email" => _email}) do
    render(conn, :create)
  end
end
