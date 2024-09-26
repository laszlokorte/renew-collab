defmodule RenewCollabWeb.SymbolController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Symbols

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    shapes = Symbols.list_shapes()

    render(conn, :index, shapes: shapes)
  end
end
