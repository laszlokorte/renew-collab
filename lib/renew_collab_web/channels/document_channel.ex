defmodule RenewCollabWeb.DocumentChannel do
  use RenewCollabWeb, :channel

  alias RenewCollabWeb.Presence

  use Phoenix.VerifiedRoutes,
    router: RenewCollabWeb.Router,
    endpoint: RenewCollabWeb.Endpoint

  @impl true
  def join("document:" <> documet_id, payload, socket) do
    if authorized?(documet_id, payload) do
      send(self(), :after_join)
      {:ok, assign(socket, :document_id, documet_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("ping", payload, socket) do
    # {:noreply, socket}
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in(
        "draw_line",
        %{},
        socket
      ) do
    {:reply, {:ok, 42}, socket}
  end

  @impl true
  def handle_in(_, _payload, socket) do
    {:noreply, socket}
    # {:noreply, socket}
    # {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.current_account.account_id, %{
        online_at: inspect(System.system_time(:second)),
        username: socket.assigns.current_account.username,
        color: make_color(socket.assigns.current_account.account_id)
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(documet_id, _payload) do
    with %RenewCollab.Document.Document{} <- RenewCollab.Renew.get_document!(documet_id) do
      true
    else
      _ -> false
    end
  end

  defp make_color(account_id) do
    hue = to_charlist(account_id) |> Enum.sum() |> rem(360)
    "hsl(#{hue}, 70%, 40%)"
  end
end
