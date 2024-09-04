defmodule RenewCollabWeb.ElementController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Renew
  alias RenewCollab.Hierarchy.Layer

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{"document_id" => document_id}) do
    document = Renew.get_document!(document_id)
    elements = Renew.list_elements(document)
    render(conn, :index, elements: elements)
  end

  def create(conn, %{"document_id" => document_id, "element" => element_params}) do
    document = Renew.get_document!(document_id)

    with {:ok, %Layer{} = element} <- Renew.create_element(document, element_params) do
      RenewCollabWeb.Endpoint.broadcast!(
        "document:#{document_id}",
        "element:new",
        Map.take(element, [:id, :z_index, :position_x, :position_y])
        |> Map.put("href", url(~p"/api/documents/#{document_id}/elements/#{element}"))
      )

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document.id}/elements/#{element}")
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

    with {:ok, %Layer{} = element} <- Renew.update_element(element, element_params) do
      render(conn, :show, element: element)
    end
  end

  def delete(conn, %{"document_id" => document_id, "id" => id}) do
    document = Renew.get_document!(document_id)
    element = Renew.get_element!(document, id)

    with {:ok, %Layer{}} <- Renew.delete_element(element) do
      send_resp(conn, :no_content, "")
    end
  end
end
