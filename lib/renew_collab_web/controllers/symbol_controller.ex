defmodule RenewCollabWeb.SymbolController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Symbol

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    shapes = Symbol.list_shapes()

    if Enum.count(shapes) < 5 do
      Symbo.reset()

      shapes = Symbol.list_shapes()
      render(conn, :index, shapes: shapes)
    else
      render(conn, :index, shapes: shapes)
    end
  end
end
