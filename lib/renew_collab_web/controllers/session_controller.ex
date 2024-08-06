defmodule RenewCollabWeb.SessionController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def new(conn, %{} = _params) do
    with token <- RenewCollabWeb.Token.sign(%{user_id: 42}) do
      render(conn, :show, token: token)
    else
      x ->
        dbg(x)
        render(conn, :show, %{:error => "Authentication failed"})
    end
  end
end
