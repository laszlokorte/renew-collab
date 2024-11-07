defmodule RenewCollab.Connection.WaypointTangent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "waypoint_tangent" do
    field :position_x, :float
    field :position_y, :float
    field :incoming, :boolean
    belongs_to :waypoint, RenewCollab.Connection.Waypoint

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(waypoint_tangent, attrs) do
    waypoint_tangent
    |> cast(attrs, [:position_x, :position_y, :waypoint_id])
    |> unique_constraint([:waypoint, :incoming])
    |> validate_required([:position_x, :position_y])
  end

  def change_position(waypoint_tangent, attrs) do
    waypoint_tangent
    |> cast(attrs, [
      :position_x,
      :position_y
    ])
  end

  defmodule Snapshotter do
    alias RenewCollab.Connection.WaypointTangent
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :waypoint_tangents
    def schema(), do: WaypointTangent

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        join: t in assoc(w, :tangents),
        select: %{
          id: t.id,
          position_x: t.position_x,
          position_y: t.position_y,
          waypoint_id: t.waypoint_id,
          inserted_at: w.inserted_at,
          updated_at: w.updated_at
        }
      )
    end
  end
end
