defmodule RenewCollabWeb.SessionController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def new(conn, %{"email" => email, "password" => password}) do
    account = RenewCollab.Auth.get_account_by_email_and_password(email, password)

    if account do
      render(conn, :show,
        token: RenewCollabWeb.Token.sign(%{account_id: account.id, email: email})
      )
    else
      conn |> put_status(:unauthorized) |> render(:show, %{:error => "Authentication failed"})
    end
  end
end
