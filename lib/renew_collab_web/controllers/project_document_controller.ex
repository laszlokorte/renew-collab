defmodule RenewCollabWeb.ProjectDocumentController do
  use RenewCollabWeb, :controller

  alias RenewCollabProj.Projects
  alias RenewCollab.Renew
  alias RenewCollab.Document.Document

  action_fallback(RenewCollabWeb.FallbackController)

  def index(conn, %{"project_id" => project_id}) do
    documents = Renew.list_documents(Projects.find_project(project_id))
    render(conn, :index, project_id: project_id, documents: documents)
  end

  def create(conn, %{"project_id" => project_id, "document" => document_params}) do
    with {:ok, %Document{} = document} <- Renew.create_document(document_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, project_id: project_id, document: document)
    end
  end

  def create(conn, %{"project_id" => project_id}) do
    with {:ok, %Document{} = document} <-
           Renew.create_document(%{name: "Untitled", kind: "de.renew.gui.CPNDrawing"}) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, project_id: project_id, document: document)
    end
  end
end
