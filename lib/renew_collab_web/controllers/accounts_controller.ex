defmodule RenewCollabWeb.AccountsController do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    accounts =
      %Views.GlobalAccounts{}
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :index,
      accounts: accounts,
      new: RenewCollabAuth.Auth.change_account(%RenewCollabAuth.Entities.Account{})
    )
  end

  def create(conn, %{
        "account" => %{"email" => email, "password" => password, "is_admin" => is_admin}
      }) do
    %Actions.AccountCreateAsAdmin{email: email, password: password, is_admin: is_admin}
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: ~p"/accounts")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :index, new: changeset, accounts: RenewCollabAuth.Auth.get_accounts())
    end
  end

  def delete(conn, %{"id" => id}) do
    %Actions.AccountDeleteAsAdmin{account_id: id}
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      :ok ->
        conn
        |> put_flash(:info, "Account deleted successfully.")
        |> redirect(to: ~p"/accounts")

      _ ->
        conn
        |> put_flash(:info, "Deleting Account failed")
        |> redirect(to: ~p"/accounts")
    end
  end
end
