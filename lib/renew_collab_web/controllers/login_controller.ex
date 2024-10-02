defmodule RenewCollabWeb.LoginController do
  use RenewCollabWeb, :controller

  def index(conn, _params) do
    render(conn, :index,
      changeset:
        RenewCollabAuth.Entites.LoginAttempt.changeset(
          %RenewCollabAuth.Entites.LoginAttempt{},
          %{}
        )
    )
  end

  def login(conn, %{"login_attempt" => _login}) do
    # render(conn, :index, changeset: RenewCollabAuth.Entites.LoginAttempt.changeset(%RenewCollabAuth.Entites.LoginAttempt{}, login))
    conn
    |> put_flash(:info, "Login successful")
    |> redirect(to: ~p"/")
  end
end
