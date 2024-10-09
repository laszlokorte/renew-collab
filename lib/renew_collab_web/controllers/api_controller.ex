defmodule RenewCollabWeb.ApiController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    render(conn, :index)
  end

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
