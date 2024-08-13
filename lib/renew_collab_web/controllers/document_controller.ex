defmodule RenewCollabWeb.DocumentController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Renew
  alias RenewCollab.Document.Document
  alias RenewCollab.Element.Element

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

  def update(conn, %{"id" => id, "document" => document_params}) do
    document = Renew.get_document!(id)

    with {:ok, %Document{} = document} <- Renew.update_document(document, document_params) do
      render(conn, :show, document: document)
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
          content_type: content_type,
          filename: filename
        }
      }) do
    with {:ok, content} <- File.read(path),
         {:ok, true} <- check_utf8_binary?(content),
         {:ok, document, refs} <- Renewex.parse_string(content),
         %Renewex.Storable{class_name: class_name, fields: %{figures: figures}} <- document do
      figs = figures |> Enum.map(&Enum.at(refs, elem(&1, 1))) |> Enum.to_list()

      elements =
        for %Renewex.Storable{fields: %{fOriginX: fOriginX, fOriginY: fOriginY}} <- figs do
          %{"position_x" => fOriginX, "position_y" => fOriginY, "z_index" => 0}
        end

      document =
        create(conn, %{
          "document" => %{"name" => filename, "kind" => class_name, "elements" => elements}
        })

      document
    else
      e ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{"error" => "Not a valid renew file"})
        |> halt()
    end
  end

  defp check_utf8_binary?(binary) do
    if :unicode.characters_to_binary(binary, :utf8, :utf8) == binary do
      {:ok, true}
    else
      {:ok, false}
    end
  end
end
