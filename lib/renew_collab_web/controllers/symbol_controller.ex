defmodule RenewCollabWeb.SymbolController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollab.Symbols

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    shapes =
      %Views.GlobalSymbolsList{}
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :index, shapes: shapes)
  end
end
