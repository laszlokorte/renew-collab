defmodule RenewCollabAuth.Commands.ApplyPasswordResetRequest do
  alias RenewCollabAuth.Entities.Account
  alias RenewCollabAuth.Entities.AccountPasswordResetRequest
  import Ecto.Query, warn: false

  defstruct [:reset_id, :account]

  def new(%{
        reset_id: reset_id,
        account: account
      }) do
    %__MODULE__{
      reset_id: reset_id,
      account: account
    }
  end

  def multi(%__MODULE__{
        reset_id: reset_id,
        account: change
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :reset_request,
      from(r in AccountPasswordResetRequest,
        join: a in assoc(r, :account),
        where: r.id == ^reset_id,
        preload: [
          account: a
        ]
      )
    )
    |> Ecto.Multi.update(
      :account,
      fn %{reset_request: %{account: acc}} ->
        acc |> Account.safe_update_changeset(change)
      end
    )
    |> Ecto.Multi.update(
      :update_request,
      fn %{reset_request: reset} ->
        reset
        |> AccountPasswordResetRequest.changeset(%{
          been_used: true
        })
      end
    )
  end
end
