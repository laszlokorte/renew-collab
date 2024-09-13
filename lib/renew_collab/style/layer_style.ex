defmodule RenewCollab.Style.LayerStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "layer_style" do
    field :opacity, :float
    field :background_color, :string
    field :border_color, :string
    field :border_width, :string
    field :border_dash_array, :string
    belongs_to :layer, RenewCollab.Hierarchy.Layer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(layer_style, attrs) do
    layer_style
    |> cast(attrs, [
      :opacity,
      :background_color,
      :border_color,
      :border_width,
      :border_dash_array
    ])
    # |> validate_required([:opacity, :background_color, :border_color, :border_width])
    |> unique_constraint(:element_id)
  end
end
