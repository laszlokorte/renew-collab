defmodule RenewCollabAuth.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias RenewCollabAuth.Repo

  alias RenewCollabAuth.Entites.Account
  alias RenewCollabAuth.Entites.SessionToken

  def get_accounts(), do: Repo.all(Account)

  def count_accounts(), do: Repo.one!(from(a in Account, select: count(a.id)))

  def count_sessions(), do: Repo.one!(from(a in SessionToken, select: count(a.id)))

  def get_account(id), do: Repo.get(Account, id)

  def get_account!(id), do: Repo.get!(Account, id)

  def get_account_by_email(email), do: Repo.get_by(Account, email: email)

  def get_account_by_email_and_password(email, password) do
    account = RenewCollabAuth.Auth.get_account_by_email(email)

    if account && Account.valid_password?(account, password) do
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
    |> Repo.insert()
  end

  def create_account(email, password, is_admin \\ false) do
    create_account(%{
      "email" => email,
      "new_password" => password,
      "is_admin" => is_admin
    })
  end

  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  def generate_account_session_token(user) do
    {token, session_token} = SessionToken.build_session_token(user)
    Repo.insert!(session_token)
    token
  end

  def delete_account_session_token(token) do
    Repo.delete_all(SessionToken.by_token_and_context_query(token, "session"))
    :ok
  end

  def get_account_by_session_token(token) do
    {:ok, query} = SessionToken.verify_session_token_query(token)
    Repo.one(query)
  end
end
