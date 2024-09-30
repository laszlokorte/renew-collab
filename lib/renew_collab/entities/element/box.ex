defmodule RenewCollab.Element.Box do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_box" do
    field :position_x, :float
    field :position_y, :float
    field :width, :float
    field :height, :float
    field :symbol_shape_attributes, :map
    belongs_to :symbol_shape, RenewCollab.Symbol.Shape
    belongs_to :layer, RenewCollab.Hierarchy.Layer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_box, attrs) do
    element_box
    |> cast(attrs, [
      :position_x,
      :position_y,
      :width,
      :height,
      :symbol_shape_id,
      :symbol_shape_attributes
    ])
    |> validate_required([:position_x, :position_y, :width, :height])
    |> unique_constraint(:element_id)
  end

  def change_size(element_box, attrs) do
    element_box
    |> cast(attrs, [
      :position_x,
      :position_y,
      :width,
      :height
    ])
  end

  defmodule Snapshotter do
    alias RenewCollab.Element.Box
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :boxes
    def schema(), do: Box

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: b in assoc(l, :box),
        select: %{
          id: b.id,
          layer_id: b.layer_id,
          position_x: b.position_x,
          position_y: b.position_y,
          width: b.width,
          height: b.height,
          symbol_shape_attributes: b.symbol_shape_attributes,
          symbol_shape_id: b.symbol_shape_id,
          inserted_at: b.inserted_at,
          updated_at: b.updated_at
        }
      )
    end
  end
end
