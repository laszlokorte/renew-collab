defmodule RenewCollab.Connection.Bond do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "connection_bond" do
    belongs_to :element_edge, RenewCollab.Element.Edge, foreign_key: :element_edge_id
    belongs_to :socket, RenewCollab.Connection.Socket
    belongs_to :layer, RenewCollab.Hierarchy.Layer
    field :kind, Ecto.Enum, values: [:source, :target], null: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_connection_bond, attrs) do
    element_connection_bond
    |> cast(attrs, [:element_edge_id, :socket_id, :layer_id, :kind])
    |> validate_required([:socket_id, :layer_id, :kind])
    |> unique_constraint([:element_edge_id, :kind])
  end

  defmodule Snapshotter do
    alias RenewCollab.Connection.Bond
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :bonds
    def schema(), do: Bond

    def query(document_id) do
      import Ecto.Query, warn: false

      from(b in Bond,
        join: e in assoc(b, :element_edge),
        join: l in assoc(e, :layer),
        where: l.document_id == ^document_id,
        select: %{
          id: b.id,
          element_edge_id: b.element_edge_id,
          layer_id: b.layer_id,
          socket_id: b.socket_id,
          kind: b.kind,
          inserted_at: b.inserted_at,
          updated_at: b.updated_at
        }
      )
    end
  end
end
