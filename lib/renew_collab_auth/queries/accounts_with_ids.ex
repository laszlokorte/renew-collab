defmodule RenewCollabAuth.Queries.AccountsWithIds do
  import Ecto.Query
  alias RenewCollabAuth.Entities.Account

  defstruct [:account_ids]

  def new(%{account_ids: accounts_ids}) do
    %__MODULE__{account_ids: accounts_ids}
  end

  def multi(%__MODULE__{account_ids: accounts_ids}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(:result, from(a in Account, where: a.id in ^accounts_ids))
  end
end
