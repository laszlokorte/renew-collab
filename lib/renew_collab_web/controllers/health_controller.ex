defmodule RenewCollabWeb.HealthController do
  use RenewCollabWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
