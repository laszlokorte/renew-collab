defmodule RenewCollabWeb.ApiSessionJSON do
  use RenewCollabWeb, :verified_routes

  def auth_error(%{}) do
    %{message: "Invalid Login"}
  end

  def auth(%{account: %RenewCollabAuth.Entites.Account{id: id, email: email}}) do
    %{token: RenewCollabWeb.Token.sign(%{account_id: id, email: email})}
  end
end
