defmodule RenewCollabWeb.LiveSocket do
  use Phoenix.Socket

  channel "live:document:*", RenewCollabWeb.LiveDocumentChannel
  channel "project-documents:*", RenewCollabWeb.LiveDocumentsChannel

  channel "live:simulation:*", RenewCollabWeb.LiveSimulationChannel
  channel "project-simulations:*", RenewCollabWeb.LiveSimulationsChannel
  channel "my-projects", RenewCollabWeb.LiveProjectsChannel
  channel "my-invitations", RenewCollabWeb.LiveInvitationsChannel
  channel "project:*", RenewCollabWeb.LiveProjectChannel

  channel "live:net_instance:*", RenewCollabWeb.LiveSimulationNetInstanceChannel
  channel "live:net_instance_bindings:*", RenewCollabWeb.LiveSimulationNetInstanceBindingsChannel
  channel "live:simulation_links:*", RenewCollabWeb.LiveSimulationLinksChannel
  channel "live:simulation_log:*", RenewCollabWeb.LiveSimulationLogChannel
  channel "live:simulation_breakpoints:*", RenewCollabWeb.LiveSimulationBreakpointsChannel

  channel "live:net_instance_bindings:*",
          RenewCollabWeb.LiveSimulationNetInstanceTransitionBindingsChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    RenewCollabWeb.Token.verify(token)
    |> case do
      {:ok, %{account: %{id: account_id, email: email}}} ->
        {:ok, assign(socket, :current_account, %{id: account_id, username: email})}

      _error ->
        {:error, "Invalid Token"}
    end
  end

  @impl true
  def connect(%{}, _socket, _connect_info) do
    {:error, "Invalid Token"}
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
