defmodule RenewCollabWeb.DocumentsChannel do
  use RenewCollabWeb, :channel

  @impl true
  def join("documents", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in(_, _payload, socket) do
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
