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
      :socket_schema_id,
      :layer_id
    ])
    |> validate_required([:socket_schema_id])
    |> unique_constraint(:layer_id)
  end

  defmodule Snapshotter do
    alias RenewCollab.Element.Interface
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :interfaces
    def schema(), do: Interface

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: i in assoc(l, :interface),
        select: %{
          id: i.id,
          layer_id: i.layer_id,
          socket_schema_id: i.socket_schema_id,
          inserted_at: i.inserted_at,
          updated_at: i.updated_at
        }
      )
    end
  end
end
