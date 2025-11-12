defmodule RenewCollabWeb.MyAccountController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def show(conn, _params) do
    conn
    |> render(:show, %{
      changeset:
        RenewCollabAuth.Entities.ChangePasswordAttempt.changeset(
          %RenewCollabAuth.Entities.ChangePasswordAttempt{},
          %{}
        )
    })
  end

  def change_password(conn, _params) do
    conn
    |> put_flash(:info, "Password changed")
    |> redirect(to: ~p"/account/me")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Account deleted")
    |> redirect(to: ~p"/")
  end
end
