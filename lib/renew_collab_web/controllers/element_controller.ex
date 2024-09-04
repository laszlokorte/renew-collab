defmodule RenewCollabWeb.ElementController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Renew
  alias RenewCollab.Hierarchy.Layer

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, %{"document_id" => document_id}) do
    document = Renew.get_document_with_elements!(document_id)
    render(conn, :index, elements: document.elements)
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
end
