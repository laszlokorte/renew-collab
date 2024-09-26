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
end
