defmodule RenewCollabWeb.ApiSessionController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def auth(conn, %{"email" => email, "password" => password}) do
    RenewCollabAuth.Auth.get_account_by_email_and_password(
      email,
      password
    )
    |> case do
      %RenewCollabAuth.Entities.Account{} = account ->
        render(conn, :auth, %{
          account: account
        })

      nil ->
        conn |> put_status(:unauthorized) |> render(:auth_error)
    end
  end
end
