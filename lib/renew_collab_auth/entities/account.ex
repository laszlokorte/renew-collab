defmodule RenewCollabAuth.Entites.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account" do
    field :password, :string, redact: true
    field :new_password, :string, virtual: true, redact: true
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :new_password])
    |> validate_required([:email, :new_password])
    |> unique_constraint(:email)
    |> maybe_hash_password()
  end

  defp maybe_hash_password(changeset) do
    # hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :new_password)

    if password && changeset.valid? do
      changeset
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:new_password)
    else
      changeset
    end
  end

  def valid_password?(
        %RenewCollabAuth.Entites.Account{password: hashed_password},
        entered_pasword
      )
      when is_binary(hashed_password) and byte_size(entered_pasword) > 0 do
    dbg(hashed_password)
    Pbkdf2.verify_pass(entered_pasword, hashed_password)
  end

  def valid_password?(_, _) do
    dbg("x")
    Pbkdf2.no_user_verify()
    false
  end
end
