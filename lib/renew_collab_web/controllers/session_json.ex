defmodule RenewCollabWeb.SessionJSON do
  use RenewCollabWeb, :verified_routes

  def show(%{token: token}) do
    %{token: token}
  end

  def show(%{error: error}) do
    %{error: error}
  end
end
