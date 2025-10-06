defmodule RenewCollabWeb.SystemController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    render(conn, :index)
  end

  def reset(conn, _params) do
    conn |> put_flash(:info, "Success!") |> redirect(to: ~p"/system")
  end
end
