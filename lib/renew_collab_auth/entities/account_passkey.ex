defmodule RenewCollabAuth.Entities.AccountPasskey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account_passkey" do
    belongs_to :account, RenewCollabAuth.Entities.Account
    field :label, :binary
    field :key_id, :binary
    field :public_key, :binary
    field :last_used_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:label, :key_key, :public_key])
    |> validate_required([:key_id, :public_key, :account_id])
    |> unique_constraint([:key_id])
    |> unique_constraint([:account_id, :label])
  end
end
