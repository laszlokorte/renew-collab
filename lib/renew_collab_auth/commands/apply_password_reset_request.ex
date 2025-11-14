defmodule RenewCollabAuth.Commands.ApplyPasswordResetRequest do
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
        reset_id: _reset_id,
        account: _account
      }) do
    Ecto.Multi.new()
  end
end
