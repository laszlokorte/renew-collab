defmodule RenewCollabWeb.ElementController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Renew
  alias RenewCollab.Renew.Element

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{"document_id" => document_id}) do
    document = Renew.get_document!(document_id)
    elements = Renew.list_elements(document)
    render(conn, :index, elements: elements)
  end

  def create(conn, %{"document_id" => document_id, "element" => element_params}) do
    document = Renew.get_document!(document_id)

    with {:ok, %Element{} = element} <- Renew.create_element(document, element_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/#{document.id}/element/#{element}")
      |> render(:show, element: element)
    end
  end

  def show(conn, %{"document_id" => document_id, "id" => id}) do
    document = Renew.get_document!(document_id)
    element = Renew.get_element!(document, id)
    render(conn, :show, element: element)
  end

  def update(conn, %{"document_id" => document_id, "id" => id, "element" => element_params}) do
    document = Renew.get_document!(document_id)
    element = Renew.get_element!(document, id)

    with {:ok, %Element{} = element} <- Renew.update_element(element, element_params) do
      render(conn, :show, element: element)
    end
  end

  def delete(conn, %{"document_id" => document_id, "id" => id}) do
    document = Renew.get_document!(document_id)
    element = Renew.get_element!(document, id)

    with {:ok, %Element{}} <- Renew.delete_element(element) do
      send_resp(conn, :no_content, "")
    end
  end
end
