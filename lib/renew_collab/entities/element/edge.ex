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
      where: [kind: :source],
      foreign_key: :element_edge_id

    has_one :target_bond, RenewCollab.Connection.Bond,
      on_delete: :delete_all,
      where: [kind: :target],
      foreign_key: :element_edge_id

    has_many :bonds, RenewCollab.Connection.Bond,
      on_delete: :delete_all,
      foreign_key: :element_edge_id,
      foreign_key: :element_edge_id

    has_one :style, RenewCollab.Style.EdgeStyle, on_delete: :delete_all

    has_many :waypoints, RenewCollab.Connection.Waypoint,
      on_delete: :delete_all,
      preload_order: [asc: :sort]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_edge, attrs) do
    element_edge
    |> cast(attrs, [:source_x, :source_y, :target_x, :target_y, :cyclic])
    |> cast_assoc(:source_bond, with: &source_bond_changeset/2)
    |> cast_assoc(:target_bond, with: &target_bond_changeset/2)
    |> cast_assoc(:style)
    |> cast_assoc(:waypoints)
    |> validate_required([:source_x, :source_y, :target_x, :target_y])
    |> unique_constraint(:element_id)
  end

  defp source_bond_changeset(bond, attrs) do
    bond
    |> change()
    |> put_change(:kind, :source)
    |> put_change(:element_edge_id, bond.element_edge_id)
    |> RenewCollab.Connection.Bond.changeset(attrs)
  end

  defp target_bond_changeset(bond, attrs) do
    bond
    |> change()
    |> put_change(:kind, :target)
    |> put_change(:element_edge_id, bond.element_edge_id)
    |> RenewCollab.Connection.Bond.changeset(attrs)
  end

  def change_position(element_edge, attrs) do
    element_edge
    |> cast(attrs, [
      :source_x,
      :source_y,
      :target_x,
      :target_y
    ])
  end

  def attribute_changeset(element_edge, attrs) do
    element_edge
    |> cast(attrs, [
      :cyclic
    ])
  end

  defmodule Snapshotter do
    alias RenewCollab.Element.Edge
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :edges
    def schema(), do: Edge

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: e in assoc(l, :edge),
        select: %{
          id: e.id,
          layer_id: e.layer_id,
          source_x: e.source_x,
          source_y: e.source_y,
          target_x: e.target_x,
          target_y: e.target_y,
          cyclic: e.cyclic,
          inserted_at: e.inserted_at,
          updated_at: e.updated_at
        }
      )
    end
  end
end
