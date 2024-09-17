defmodule RenewCollab.Element.Interface do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_interface" do
    belongs_to :socket_schema, RenewCollab.Connection.SocketSchema
    belongs_to :layer, RenewCollab.Hierarchy.Layer

    has_many :sockets, through: [:socket_schema, :sockets]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_interface, attrs) do
    element_interface
    |> cast(attrs, [
      :socket_schema_id
    ])
    |> validate_required([:socket_schema_id])
    |> unique_constraint(:layer_id)
  end
end
