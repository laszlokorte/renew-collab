defmodule RenewCollabAuth.Queries.RegisrationById do
  import Ecto.Query
  alias RenewCollabAuth.Entities.Registration

  defstruct [:registration_id]

  def new(%{registration_id: registration_id}) do
    %__MODULE__{registration_id: registration_id}
  end

  def multi(%__MODULE__{registration_id: registration_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:result, from(r in Registration, where: r.id == ^registration_id))
  end
end
