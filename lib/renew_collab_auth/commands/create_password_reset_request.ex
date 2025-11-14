defmodule RenewCollabAuth.Commands.CreatePasswordResetRequest do
  alias RenewCollabAuth.Entities.AccountPasswordResetRequest
  alias RenewCollabAuth.Entities.Account
  import Ecto.Query, warn: false

  defstruct [:email]

  def new(%{
        email: email
      }) do
    %__MODULE__{
      email: email
    }
  end

  def multi(%__MODULE__{
        email: email
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :account,
      from(a in Account, where: a.email == ^email)
    )
    |> Ecto.Multi.insert(
      :reset_request,
      fn
        %{account: nil} ->
          %AccountPasswordResetRequest{account_id: nil, been_used: nil}
          |> AccountPasswordResetRequest.changeset(%{been_used: false})

        %{account: %{id: account_id}} ->
          %AccountPasswordResetRequest{account_id: account_id}
          |> AccountPasswordResetRequest.changeset(%{been_used: false})
      end,
      returning: true
    )
  end
end
