defmodule RenewCollabWeb.ProjectDocumentController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollab.Document.Document
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher

  action_fallback(RenewCollabWeb.FallbackController)

  def index(conn, %{"project_id" => project_id}) do
    documents =
      %Views.ProjectDocumentsList{
        project_id: project_id
      }
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :index, project_id: project_id, documents: documents)
  end

  def create(conn, %{"project_id" => project_id, "document" => document_data}) do
    %Actions.DocumentCreateInProject{project_id: project_id, document_data: document_data}
    |> Dispatcher.perform_as(conn.assigns.current_user)
    |> case do
      {:ok, %Document{} = document} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/documents/#{document}")
        |> render(:show, project_id: project_id, document: document)
    end
  end

  def create(conn, %{"project_id" => project_id}) do
    with {:ok, %Document{} = document} <-
           %Actions.DocumentCreateInProject{
             project_id: project_id,
             document_data: %{name: "Untitled", kind: "de.renew.gui.CPNDrawing"}
           }
           |> Dispatcher.perform_as(conn.assigns.current_account) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, project_id: project_id, document: document)
    end
  end
end
