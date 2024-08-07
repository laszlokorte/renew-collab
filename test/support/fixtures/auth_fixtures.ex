defmodule RenewCollab.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RenewCollab.Auth` context.
  """

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        email: "some email",
        password: "some password"
      })
      |> RenewCollab.Auth.create_account()

    account
  end
end
