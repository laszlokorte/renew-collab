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
end
