defmodule RenewCollabWeb.DocumentChannel do
  use RenewCollabWeb, :channel

  @impl true
  def join("document:" <> documet_id, payload, socket) do
    if authorized?(documet_id, payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (document:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(documet_id, _payload) do
    with %RenewCollab.Renew.Document{} <- RenewCollab.Renew.get_document!(documet_id) do
      true
    else
      _ ->
        false
    end
  end
end
