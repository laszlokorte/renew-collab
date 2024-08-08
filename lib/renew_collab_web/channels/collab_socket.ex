defmodule RenewCollabWeb.CollabSocket do
  use Phoenix.Socket

  channel "document:*", RenewCollabWeb.DocumentChannel

  channel "documents", RenewCollabWeb.DocumentsChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, data} <- RenewCollabWeb.Token.verify(token) do
      {:ok, assign(socket, :current_account, data.account_id)}
    else
      _error ->
        {:error, "Invalid Token"}
    end
  end

  # Socket IDs are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.RenewCollabWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
