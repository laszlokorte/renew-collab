defmodule RenewCollabAuth.Queries.PendingPasswordResetRequest do
  import Ecto.Query
  alias RenewCollabAuth.Entities.AccountPasswordResetRequest

  defstruct [:reset_id]

  def new(%{reset_id: reset_id}) do
    %__MODULE__{reset_id: reset_id}
  end

  def multi(%__MODULE__{reset_id: reset_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(r in AccountPasswordResetRequest, where: r.id == ^reset_id and not r.been_used)
    )
  end
end
