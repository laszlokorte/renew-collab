defmodule RenewCollab.Connection.SocketSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "socket_schema" do
    field :name, :string
    has_many :sockets, RenewCollab.Connection.Socket

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(socket_schema, attrs) do
    socket_schema
    |> cast(attrs, [:name])
    |> cast_assoc(:sockets)
    |> validate_required([:name])
    |> unique_constraint(:element_id)
  end
end
