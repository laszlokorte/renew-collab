defmodule RenewCollabWeb.AccountsController do
  use RenewCollabWeb, :controller

  def index(conn, _params) do
    render(conn, :index,
      accounts: RenewCollabAuth.Auth.get_accounts(),
      new: RenewCollabAuth.Auth.change_account(%RenewCollabAuth.Entites.Account{})
    )
  end

  def create(conn, %{"account" => account_params}) do
    case RenewCollabAuth.Auth.create_account(account_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: ~p"/accounts")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :index, new: changeset, accounts: RenewCollabAuth.Auth.get_accounts())
    end
  end

  def delete(conn, %{"id" => id}) do
    account = RenewCollabAuth.Auth.get_account!(id)
    {:ok, _account} = RenewCollabAuth.Auth.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: ~p"/accounts")
  end
end
