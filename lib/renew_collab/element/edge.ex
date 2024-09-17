defmodule RenewCollab.Element.Edge do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_edge" do
    field :source_x, :float
    field :source_y, :float
    field :target_x, :float
    field :target_y, :float
    field :cyclic, :boolean, default: false
    belongs_to :layer, RenewCollab.Hierarchy.Layer

    has_one :source_bond, RenewCollab.Connection.Bond,
      on_delete: :delete_all,
      where: [kind: :source]

    has_one :target_bond, RenewCollab.Connection.Bond,
      on_delete: :delete_all,
      where: [kind: :target]

    has_one :style, RenewCollab.Style.EdgeStyle, on_delete: :delete_all

    has_many :waypoints, RenewCollab.Connection.Waypoint, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_edge, attrs) do
    element_edge
    |> cast(attrs, [:source_x, :source_y, :target_x, :target_y, :cyclic])
    |> cast_assoc(:source_bond)
    |> cast_assoc(:target_bond)
    |> cast_assoc(:style)
    |> cast_assoc(:waypoints)
    |> validate_required([:source_x, :source_y, :target_x, :target_y])
    |> unique_constraint(:element_id)
  end
end
