defmodule RenewCollabWeb.DocumentChannel do
  use RenewCollabWeb, :channel

  alias RenewCollab.Renew
  alias RenewCollab.Document.Document
  alias RenewCollab.Element.Element

  use Phoenix.VerifiedRoutes,
    router: RenewCollabWeb.Router,
    endpoint: RenewCollabWeb.Endpoint

  @impl true
  def join("document:" <> documet_id, payload, socket) do
    if authorized?(documet_id, payload) do
      {:ok, assign(socket, :document_id, documet_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("ping", payload, socket) do
    #{:noreply, socket}
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("create_element", %{"element"=>element_params}, socket) do
    with {:ok, %Element{} = element} <- Renew.create_element(%Document{id: socket.assigns.document_id}, element_params) do
      broadcast!(socket, "element:new", 
        Map.take(element, [:id, :z_index, :position_x, :position_y]))
    else err -> dbg(err)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_in(_, payload, socket) do
    {:noreply, socket}
    #{:noreply, socket}
    #{:reply, {:ok, payload}, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(documet_id, _payload) do
    with %RenewCollab.Document.Document{} <- RenewCollab.Renew.get_document!(documet_id) do
      true
    else
      _ -> false
    end
  end
end
