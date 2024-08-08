defmodule RenewCollab.Renew.ElementConnection do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_connection" do
    field :source_x, :float
    field :source_y, :float
    field :target_x, :float
    field :target_y, :float
    belongs_to :element, RenewCollab.Renew.Element
    has_one :source_bond, RenewCollab.Renew.ElementConnectionSourceBond
    has_one :target_bond, RenewCollab.Renew.ElementConnectionTargetBond
    has_one :style, RenewCollab.Renew.ElementConnectionStyle
    has_many :waypoints, RenewCollab.Renew.ElementConnectionWaypoint

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_connection, attrs) do
    element_connection
    |> cast(attrs, [:source_x, :source_y, :target_x, :target_y])
    |> cast_assoc(:source_bond)
    |> cast_assoc(:target_bond)
    |> cast_assoc(:style)
    |> cast_assoc(:waypoints)
    |> validate_required([:source_x, :source_y, :target_x, :target_y])
    |> unique_constraint(:element_id)
  end
end
