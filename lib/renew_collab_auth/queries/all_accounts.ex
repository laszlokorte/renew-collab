defmodule RenewCollabAuth.Queries.AllAccounts do
  import Ecto.Query
  alias RenewCollabAuth.Entities.Account

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(:result, from(a in Account))
  end
end
