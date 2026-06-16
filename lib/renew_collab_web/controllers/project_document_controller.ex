defmodule RenewCollabWeb.ProjectDocumentController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Import.DocumentImport
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
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      {:ok, %Document{} = document} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/documents/#{document}")
        |> json(%{
          id: document.id,
          url: ~p"/api/documents/#{document}",
          content: %{
            name: document.name
          }
        })
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
      |> json(%{
        id: document.id,
        url: ~p"/api/documents/#{document}",
        content: %{
          name: document.name
        }
      })
    end
  end

  def import_documents(conn, %{
        "project_id" => project_id,
        "files" => files
      }) do
    for %Plug.Upload{
          path: path,
          content_type: _content_type,
          filename: filename
        } <- files,
        reduce: [] do
      :error ->
        :error

      imported_documents ->
        with {:ok, content} <- File.read(path),
             {:ok, imported = %RenewCollab.Import.Converted{}} <-
               DocumentImport.import(filename, content),
             {:ok, %Document{} = document} <-
               %Actions.DocumentCreateInProject{
                 project_id: project_id,
                 document_data: imported
               }
               |> Dispatcher.perform_as(conn.assigns.current_account) do
          [document | imported_documents]
        else
          _ ->
            :error
        end
    end
    |> case do
      :error ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{message: "Not a valid renew file"})
        |> halt()

      imported ->
        conn
        |> put_status(:created)
        |> render(:import_documents, imported: imported)
    end
  end
end
