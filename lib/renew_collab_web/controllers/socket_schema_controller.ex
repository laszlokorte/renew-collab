defmodule RenewCollabWeb.SocketSchemaController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    socket_schemas =
      %Views.GlobalSocketSchemasList{}
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :index, socket_schemas: socket_schemas)
  end
end
