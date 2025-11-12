defmodule RenewCollabAuth.Commands.CreateAccountFromRegistration do
  alias RenewCollabAuth.Entities.Registration
  import Ecto.Query, warn: false

  defstruct [:registration_id, :email, :account]

  def new(%{
        registration_id: registration_id,
        email: email,
        account: account
      }) do
    %__MODULE__{
      registration_id: registration_id,
      email: email,
      account: account
    }
  end

  def multi(%__MODULE__{
        registration_id: registration_id,
        email: email,
        account: account
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :account,
      RenewCollabAuth.Entities.Account.registration_changeset(
        %RenewCollabAuth.Entities.Account{email: email},
        account
      ),
      returning: true
    )
    |> Ecto.Multi.delete_all(
      :delete_registration,
      from(r in Registration, where: r.id == ^registration_id and r.email == ^email)
    )
  end
end
