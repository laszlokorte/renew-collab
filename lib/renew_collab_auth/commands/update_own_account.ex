defmodule RenewCollabAuth.Commands.UpdateOwnAccount do
  alias RenewCollabAuth.Entities.Account
  import Ecto.Query, warn: false

  defstruct [:account_id, :attributes]

  def new(%{
        account_id: account_id,
        attributes: attrs
      }) do
    %__MODULE__{
      account_id: account_id,
      attributes: attrs
    }
  end

  def multi(%__MODULE__{
        account_id: account_id,
        attributes: attrs
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :account,
      %Account{id: account_id, is_admin: nil}
      |> Account.safe_update_changeset(attrs)
    )
  end
end
