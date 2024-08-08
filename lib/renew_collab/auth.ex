defmodule RenewCollab.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Auth.Account

  def get_account!(id), do: Repo.get!(Account, id)

  def get_account_by_email(email), do: Repo.get_by(Account, email: email)

  def get_account_by_email_and_password(email, password) do
    account = RenewCollab.Auth.get_account_by_email(email)

    if account && Bcrypt.verify_pass(password, account.password) do
      account
    else
      nil
    end
  end

end
