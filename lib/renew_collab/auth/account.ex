defmodule RenewCollab.Auth.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account" do
    field :password, :string, redact: true
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> prepare_changes(fn changeset -> 
      update_change(changeset, :password, &Bcrypt.hash_pwd_salt(&1))
    end)
  end
end
