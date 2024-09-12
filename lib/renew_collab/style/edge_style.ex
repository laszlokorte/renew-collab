defmodule RenewCollab.Style.EdgeStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_edge_style" do
    field :stroke_width, :string, default: "1"
    field :stroke_color, :string, default: "black"
    field :stroke_join, :string
    field :stroke_cap, :string
    field :stroke_dash_array, :string
    field :source_tip, :string
    field :target_tip, :string
    field :smoothness, :string

    belongs_to :source_tip_symbol_shape, RenewCollab.Symbol.Shape
    belongs_to :target_tip_symbol_shape, RenewCollab.Symbol.Shape

    belongs_to :edge, RenewCollab.Element.Edge

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_edge_style, attrs) do
    element_edge_style
    |> cast(attrs, [
      :stroke_width,
      :stroke_color,
      :stroke_join,
      :stroke_cap,
      :stroke_dash_array,
      :source_tip,
      :target_tip,
      :smoothness,
      :source_tip_symbol_shape_id,
      :target_tip_symbol_shape_id
    ])
    # |> validate_required([:stroke_width, :stroke_color, :stroke_join, :stroke_cap, :stroke_dash_array, :source_tip, :target_tip, :smoothness])
    |> unique_constraint(:element_connection_id)
  end
end
