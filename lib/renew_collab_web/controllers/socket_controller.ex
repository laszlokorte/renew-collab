defmodule RenewCollabWeb.SocketSchemaController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Sockets

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    socket_schemas = Sockets.all_socket_schemas()

    render(conn, :index, socket_schemas: socket_schemas)
  end
end
