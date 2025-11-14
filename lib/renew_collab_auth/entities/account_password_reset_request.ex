defmodule RenewCollabAuth.Entities.AccountPasswordResetRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account_password_reset_request" do
    belongs_to :account, RenewCollabAuth.Entities.Account
    field :been_used, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:been_used])
    |> validate_required([:account_id, :been_used])
  end
end
