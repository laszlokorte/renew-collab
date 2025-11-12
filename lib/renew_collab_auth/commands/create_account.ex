defmodule RenewCollabAuth.Commands.CreateAccount do
  alias RenewCollabAuth.Entities.Account
  import Ecto.Query, warn: false

  defstruct [:account]

  def new(%{
        account: account
      }) do
    %__MODULE__{
      account: account
    }
  end

  def multi(%__MODULE__{
        account: account
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :account,
      %Account{} |> Account.changeset(account)
    )
  end
end
