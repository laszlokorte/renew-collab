defmodule RenewCollabWeb.LiveDocuments do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollab.Renew

  @topic "documents"

  def mount(_params, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)
    socket = assign(socket, :documents, Renew.list_documents())
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h2>Documents</h2>

      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Created</th>
            <th>Last Updated</th>
          </tr>
        </thead>
        <tbody>
          <%= for document <- @documents do %> 
        <tr>
          <td><.link href={~p"/live/document/#{document.id}"}><%= document.name %></.link></td>
          <td><%= document.inserted_at %></td>
          <td><%= document.updated_at %></td>
          <td><button type="button" phx-click="duplicate" phx-value-id={document.id}>Duplicate</button></td>
          <td><button type="button" phx-click="delete" phx-value-id={document.id}>Delete</button></td>
        </tr>
      <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def handle_event("duplicate", %{"id" => id}, socket) do
    # TODO
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Renew.delete_document(%RenewCollab.Document.Document{id: id})

    RenewCollabWeb.Endpoint.broadcast!(
      "documents",
      "document:deleted",
      %{"id" => id}
    )

    {:noreply, socket}
  end

  def handle_info(%{topic: @topic, payload: state}, socket) do
    {:noreply, socket |> assign(:documents, Renew.list_documents())}
  end
end
