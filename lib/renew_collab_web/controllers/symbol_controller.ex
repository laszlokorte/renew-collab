defmodule RenewCollabWeb.SymbolController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Symbol

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    shapes = Symbol.list_shapes()
    render(conn, :index, shapes: shapes)
  end
end
