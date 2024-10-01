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
      RenewCollabWeb.Endpoint.broadcast!(
        "documents",
        "document:new",
        Map.take(document, [:name, :kind, :id])
        |> Map.put("href", url(~p"/api/documents/#{document}"))
      )

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, document: document)
    end
  end

  def show(conn, %{"id" => id}) do
    document = Renew.get_document_with_elements!(id)
    render(conn, :show, document: document)
  end

  def export(conn, %{"id" => id}) do
    document = Renew.get_document_with_elements!(id)

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
    {:ok, document} = RenewCollab.Clone.deep_clone_document!(id)

    conn
    |> put_resp_header(
      "content-type",
      "text/plain"
    )
    |> text(Kernel.inspect(document, pretty: true, limit: :infinity))
  end

  def template(conn, %{"id" => id}) do
    # Renew.get_document_with_elements_as_template!(id)
    document_params = %{"id" => id}

    with {:ok, %Document{} = document} <- Renew.create_document(document_params) do
      RenewCollabWeb.Endpoint.broadcast!(
        "documents",
        "document:new",
        Map.take(document, [:name, :kind, :id])
        |> Map.put("href", url(~p"/api/documents/#{document}"))
      )

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, document: document)
    end
  end

  def delete(conn, %{"id" => id}) do
    document = Renew.get_document!(id)

    with {:ok, %Document{}} <- Renew.delete_document(document) do
      RenewCollabWeb.Endpoint.broadcast!(
        "documents",
        "document:delete",
        Map.take(document, [:id])
        |> Map.put("href", url(~p"/api/documents/#{id}"))
      )

      send_resp(conn, :no_content, "")
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
      RenewCollabWeb.Endpoint.broadcast!(
        "documents",
        "document:new",
        Map.take(document, [:name, :kind, :id])
        |> Map.put("href", url(~p"/api/documents/#{document}"))
      )

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
