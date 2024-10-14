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
    case Renew.get_document_with_elements(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.json(%{message: "Not found"})
        |> halt()

      document ->
        render(conn, :show, document: document)
    end
  end

  def export(conn, %{"id" => id}) do
    case Renew.get_document_with_elements(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.json(%{message: "Not found"})
        |> halt()

      document ->
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

      imported ->
        with {:ok, content} <- File.read(path),
             {:ok,
              %RenewCollab.Import.Converted{
                name: doc_name,
                kind: kind,
                layers: layers,
                hierarchy: hierarchy,
                hyperlinks: hyperlinks,
                bonds: bonds
              }} <- DocumentImport.import(filename, content),
             {:ok, %Document{} = document} <-
               RenewCollab.Renew.create_document(
                 %{"name" => doc_name, "kind" => kind, "layers" => layers},
                 hierarchy,
                 hyperlinks,
                 bonds
               ) do
          [document | imported]
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
        |> render(:import, imported: imported)
    end
  end
end
