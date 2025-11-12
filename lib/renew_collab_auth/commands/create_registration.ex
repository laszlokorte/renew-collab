defmodule RenewCollabAuth.Commands.CreateRegistration do
  alias RenewCollabAuth.Entities.Registration
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
    |> Ecto.Multi.insert(
      :registration,
      %Registration{}
      |> Registration.changeset(%{
        email: email
      }),
      on_conflict: {:replace, [:email]},
      returning: true,
      conflict_target: [:email]
    )
  end
end
