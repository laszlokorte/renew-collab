defmodule RenewCollab.Connection.Waypoint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "waypoint" do
    field :sort, :integer
    field :position_x, :float
    field :position_y, :float
    belongs_to :edge, RenewCollab.Element.Edge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(waypoint, attrs) do
    waypoint
    |> cast(attrs, [:position_x, :position_y, :sort, :edge_id])
    |> unique_constraint([:edge, :sort])
    |> validate_required([:position_x, :position_y, :sort])
  end

  def change_position(waypoint, attrs) do
    waypoint
    |> cast(attrs, [
      :position_x,
      :position_y
    ])
  end

  defmodule Snapshotter do
    alias RenewCollab.Connection.Waypoint
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :waypoints
    def schema(), do: Waypoint

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        select: %{
          id: w.id,
          sort: w.sort,
          position_x: w.position_x,
          position_y: w.position_y,
          edge_id: w.edge_id,
          inserted_at: w.inserted_at,
          updated_at: w.updated_at
        }
      )
    end
  end
end
