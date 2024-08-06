defmodule RenewCollabWeb.SessionController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController
  @password Application.compile_env(:renew_collab, :app_password)

  def new(conn, %{"password" => password}) do
    if password == @password do
      render(conn, :show, token: RenewCollabWeb.Token.sign(%{user_id: 42}))
    else
      conn |> put_status(:unauthorized) |> render(:show, %{:error => "Authentication failed"})
    end
  end
end
