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
    field :shape, :string
    belongs_to :layer, RenewCollab.Hierarchy.Layer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_box, attrs) do
    element_box
    |> cast(attrs, [:position_x, :position_y, :width, :height, :shape])
    |> validate_required([:position_x, :position_y, :width, :height])
    |> unique_constraint(:element_id)
  end
end
