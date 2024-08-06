defmodule RenewCollabWeb.SessionController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def new(conn, %{"password" => password}) do
    if Application.fetch_env!(:renew_collab, :app_password) == password do
      render(conn, :show, token: RenewCollabWeb.Token.sign(%{user_id: 42}))
    else
      conn |> put_status(:unauthorized) |> render(:show, %{:error => "Authentication failed"})
    end
  end
end
