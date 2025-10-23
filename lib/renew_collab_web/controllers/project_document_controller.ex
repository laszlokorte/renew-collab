defmodule RenewCollabWeb.ProjectDocumentController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Document.Document
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  action_fallback(RenewCollabWeb.FallbackController)

  def index(conn, %{"project_id" => project_id}) do
    documents =
      %Views.ProjectDocumentsList{
        project_id: project_id
      }
      |> Fetcher.fetch_as(conn.assigns.current_account)

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
