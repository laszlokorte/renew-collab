defmodule RenewCollabWeb.MyAccountController do
  alias Ecto.Changeset
  alias RenewCollabCtrl.WriteAccess
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def show(conn, _params) do
    conn
    |> render(:show, %{
      changeset:
        RenewCollabAuth.Entities.Account.changeset(
          %RenewCollabAuth.Entities.Account{},
          %{}
        )
    })
  end

  def change_password(conn, %{"account" => change}) do
    action = %Actions.AccountChangePasswordAsUser{
      account_id: conn.assigns.current_account.id,
      change: change
    }

    if WriteAccess.can(conn.assigns.current_account, action) do
      action
      |> Dispatcher.perform_as(conn.assigns.current_account)
      |> case do
        {:ok, _account} ->
          conn
          |> put_flash(:info, "Account updated successfully.")
          |> redirect(to: ~p"/account/me")

        {:error, changeset} ->
          conn
          |> render(:show, %{
            changeset: changeset
          })
      end
    else
      conn
      |> render(:show, %{
        changeset:
          RenewCollabAuth.Entities.Account.safe_update_changeset(
            %RenewCollabAuth.Entities.Account{},
            change
          )
          |> Changeset.add_error(:old_password, "Old password is not correct")
          |> Map.put(:action, :update)
      })
    end
  end

  def delete(conn, _params) do
    %Actions.AccountDeleteAsUser{
      account_id: conn.assigns.current_account.id
    }
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      :ok ->
        conn
        |> put_flash(:info, "Account deleted")
        |> RenewCollabWeb.Auth.log_out_account()
        |> redirect(to: ~p"/login")

      _ ->
        conn
        |> put_flash(:info, "An error occured while deleting the account")
        |> redirect(to: ~p"/account/me")
    end
  end
end
