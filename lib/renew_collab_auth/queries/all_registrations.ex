defmodule RenewCollabAuth.Queries.AllRegistrations do
  import Ecto.Query
  alias RenewCollabAuth.Entities.Registration

  defstruct []

  def new(%{}) do
    %__MODULE__{}
  end

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(:result, from(a in Registration))
  end
end
