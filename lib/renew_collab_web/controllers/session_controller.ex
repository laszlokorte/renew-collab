defmodule RenewCollabWeb.SessionController do
  use RenewCollabWeb, :controller
  import Bcrypt.Base, only: [verify_pass: 2]

  action_fallback RenewCollabWeb.FallbackController

  def new(conn, %{"email" => email, "password" => password}) do
    account = RenewCollab.Auth.get_account_by_email(email)

    if account && verify_pass(password, account.password) do
      render(conn, :show, token: RenewCollabWeb.Token.sign(%{user_id: 42}))
    else
      conn |> put_status(:unauthorized) |> render(:show, %{:error => "Authentication failed"})
    end
  end
end
