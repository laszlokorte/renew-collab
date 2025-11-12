defmodule RenewCollabAuth.Entities.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "registration" do
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(registration, attrs) do
    conf = Application.fetch_env!(:renew_collab, RenewCollabAuth)

    registration
    |> cast(attrs, [:email])
    |> validate_format(:email, ~r/@/, message: "Must be a valid E-mail address")
    # TODO: make configurable
    |> validate_format(
      :email,
      Keyword.get(conf, :email_pattern),
      message: "Currently only selected E-mail adresses are for registration"
    )
    |> validate_required([:email])
  end
end
