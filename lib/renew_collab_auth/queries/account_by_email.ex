defmodule RenewCollabAuth.Queries.AccountByEmail do
  import Ecto.Query
  alias RenewCollabAuth.Entities.Account

  defstruct [:email]

  def new(%{email: email}) do
    %__MODULE__{email: email}
  end

  def multi(%__MODULE__{email: email}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:result, from(a in Account, where: a.email == ^email))
  end
end
