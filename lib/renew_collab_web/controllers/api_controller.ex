defmodule RenewCollabWeb.ApiController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    render(conn, :index)
  end

  def auth(conn, _params) do
    render(conn, :auth)
  end
end
