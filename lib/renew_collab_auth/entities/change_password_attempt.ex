defmodule RenewCollabAuth.Entites.ChangePasswordAttempt do
  use Ecto.Schema
  import Ecto.Changeset

  # Using embedded_schema instead of schema
  embedded_schema do
    field :old_password, :string, redact: true
    field :new_password, :string, redact: true
    field :confirm_password, :string, redact: true
  end

  @doc false
  def changeset(login, attrs) do
    login
    |> cast(attrs, [:old_password, :new_password, :confirm_password])
    |> validate_required([:old_password, :new_password, :confirm_password])
  end
end
