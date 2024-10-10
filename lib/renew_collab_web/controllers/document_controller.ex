defmodule RenewCollabWeb.DocumentController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Renew
  alias RenewCollab.Document.Document
  alias RenewCollab.Import.DocumentImport

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    documents = Renew.list_documents()
    render(conn, :index, documents: documents)
  end

  def create(conn, %{"document" => document_params}) do
    with {:ok, %Document{} = document} <- Renew.create_document(document_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, document: document)
    end
  end

  def create(conn, %{}) do
    with {:ok, %Document{} = document} <- Renew.create_document(%{name: "Untitled", kind: "mock"}) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, document: document)
    end
  end

  def show(conn, %{"id" => id}) do
    document = Renew.get_document_with_elements(id)
    render(conn, :show, document: document)
  end

  def export(conn, %{"id" => id}) do
    document = Renew.get_document_with_elements(id)

    {:ok, output} = RenewCollab.Export.DocumentExport.export(document)

    conn
    |> put_resp_header(
      "content-disposition",
      "inline; filename=\"#{document.name |> String.trim_trailing(".rnw")}_exported.rnw\""
    )
    |> put_resp_header(
      "content-type",
      "text/plain+renew"
    )
    |> text(output)
  end

  def inspect(conn, %{"id" => id}) do
    RenewCollab.Queries.StrippedDocument.new(%{document_id: id})
    |> RenewCollab.Fetcher.fetch()
    |> case do
      document ->
        conn
        |> put_resp_header(
          "content-disposition",
          "inline; filename=\"#{document.content.name}.rnx\""
        )
        |> put_resp_header(
          "content-type",
          "text/plain"
        )
        |> text(Kernel.inspect(document, pretty: true, limit: :infinity))
    end
  end

  def import(conn, %{
        "renew_file" => %Plug.Upload{
          path: path,
          content_type: _content_type,
          filename: filename
        }
      }) do
    with {:ok, content} <- File.read(path),
         {:ok, document_params, hierarchy} <- DocumentImport.import(filename, content),
         {:ok, %Document{} = document} <- Renew.create_document(document_params, hierarchy) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:import, document: document)
    else
      _e ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{"error" => "Not a valid renew file"})
        |> halt()
    end
  end
end
