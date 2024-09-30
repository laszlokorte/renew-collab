defmodule RenewCollabAuth.Entites.LoginAttempt do
  use Ecto.Schema
  import Ecto.Changeset

  # Using embedded_schema instead of schema
  embedded_schema do
    field :email, :string
    field :password, :string, redact: true
  end

  @doc false
  def changeset(login, attrs) do
    login
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
  end
end
