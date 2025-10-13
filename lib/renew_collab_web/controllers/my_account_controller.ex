defmodule RenewCollabWeb.MyAccountController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def show(conn, params) do
    conn
    |> render(:show, %{
      changeset:
        RenewCollabAuth.Entites.ChangePasswordAttempt.changeset(
          %RenewCollabAuth.Entites.ChangePasswordAttempt{},
          %{}
        )
    })
  end

  def change_password(conn, params) do
    conn
    |> put_flash(:info, "Password changed")
    |> redirect(to: ~p"/account/me")
  end
end
