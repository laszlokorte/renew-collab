defmodule RenewCollabAuth.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollabAuth.Entites.Account

  def get_accounts(), do: Repo.all(Account)

  def count_accounts(), do: Repo.one!(from(a in Account, select: count(a.id)))

  def get_account!(id), do: Repo.get!(Account, id)

  def get_account_by_email(email), do: Repo.get_by(Account, email: email)

  def get_account_by_email_and_password(email, password) do
    account = RenewCollabAuth.Auth.get_account_by_email(email)

    if account && Bcrypt.verify_pass(password, account.password) do
      account
    else
      nil
    end
  end

  def change_account(%Account{} = post, attrs \\ %{}) do
    Account.changeset(post, attrs)
  end

  def create_account(params) do
    %Account{}
    |> Account.changeset(params)
    |> RenewCollab.Repo.insert()
  end

  def create_account(email, password) do
    create_account(%{
      "email" => email,
      "password" => password
    })
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end
end