defmodule RenewCollab.Connection.ElementConnectionWaypoint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_connection_waypoint" do
    field :sort, :integer
    field :position_x, :float
    field :position_y, :float
    belongs_to :element_connection, RenewCollab.Connection.ElementConnection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_connection_waypoint, attrs) do
    element_connection_waypoint
    |> cast(attrs, [:position_x, :position_y, :sort])
    |> validate_required([:position_x, :position_y, :sort])
  end
end
