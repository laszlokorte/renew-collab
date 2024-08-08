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
