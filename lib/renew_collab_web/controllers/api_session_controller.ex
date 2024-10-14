defmodule RenewCollabWeb.ApiSessionController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def auth(conn, %{"email" => email, "password" => password}) do
    with %RenewCollabAuth.Entites.Account{} = account <-
           RenewCollabAuth.Auth.get_account_by_email_and_password(
             email,
             password
           ) do
      render(conn, :auth, %{
        account: account
      })
    else
      nil ->
        conn |> put_status(:unauthorized) |> render(:auth_error)
    end
  end
end
