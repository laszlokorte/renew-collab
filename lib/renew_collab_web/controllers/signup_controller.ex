defmodule RenewCollabWeb.SignupController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def new(conn, _params) do
    conn
    |> render(:new, %{
      changeset:
        RenewCollabAuth.Entities.Account.changeset(
          %RenewCollabAuth.Entities.Account{},
          %{}
        )
    })
  end

  def create(conn, _params) do
    conn |> put_flash(:info, "Signup complete") |> redirect(to: ~p"/")
  end
end
