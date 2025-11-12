defmodule RenewCollabAuth.Commands.DeleteAccount do
  alias RenewCollabAuth.Entities.Account
  import Ecto.Query, warn: false

  defstruct [:account_id]

  def new(%{
        account_id: account_id
      }) do
    %__MODULE__{
      account_id: account_id
    }
  end

  def multi(%__MODULE__{
        account_id: account_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_account,
      from(a in Account, where: a.id == ^account_id)
    )
  end
end
