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

      <%= for document <- @documents do %> 
        <li><.link href={~p"/live/document/#{document.id}"}><%= document.name %></.link></li>
      <% end %>
    </div>
    """
  end

  def handle_info(%{topic: @topic, payload: state}, socket) do
    {:noreply, socket |> assign(:documents, Renew.list_documents())}
  end
end
