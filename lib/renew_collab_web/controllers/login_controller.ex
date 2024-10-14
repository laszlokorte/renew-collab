defmodule RenewCollabWeb.LoginController do
  use RenewCollabWeb, :controller

  def index(conn, _params) do
    render(conn, :index,
      accounts_initialized: RenewCollabAuth.Auth.count_accounts() > 0,
      changeset:
        RenewCollabAuth.Entites.LoginAttempt.changeset(
          %RenewCollabAuth.Entites.LoginAttempt{},
          %{}
        )
    )
  end

  def login(conn, %{"login_attempt" => params}) do
    login =
      RenewCollabAuth.Entites.LoginAttempt.changeset(
        %RenewCollabAuth.Entites.LoginAttempt{},
        params
      )

    login
    |> Ecto.Changeset.apply_action(:login)
    |> case do
      {:ok, %{email: email, password: password}} ->
        nil

        with %RenewCollabAuth.Entites.Account{} = account <-
               RenewCollabAuth.Auth.get_account_by_email_and_password(
                 email,
                 password
               ) do
          {:ok, account}
        else
          _ ->
            login
            |> Ecto.Changeset.add_error(:password, "Invalid Login")
            |> Ecto.Changeset.apply_action(:login)
        end

      e ->
        e
    end
    |> case do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Login successful")
        |> RenewCollabWeb.Auth.log_in_account(account)

      {:error, login} ->
        conn
        |> put_status(:unauthorized)
        |> render(:index,
          changeset: login,
          accounts_initialized: RenewCollabAuth.Auth.count_accounts() > 0
        )
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> RenewCollabWeb.Auth.log_out_account()
  end
end
