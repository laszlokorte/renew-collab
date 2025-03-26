defmodule RenewCollab.Style.EdgeStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_edge_style" do
    field :stroke_width, :float, default: 1.0
    field :stroke_color, :string, default: "black"
    field :stroke_join, :string
    field :stroke_cap, :string
    field :stroke_dash_array, :string
    field :smoothness, Ecto.Enum, values: [:linear, :autobezier], default: :linear

    belongs_to :source_tip_symbol_shape, RenewCollab.Symbol.Shape
    belongs_to :target_tip_symbol_shape, RenewCollab.Symbol.Shape

    field :source_tip_size, :float, default: 1.0
    field :target_tip_size, :float, default: 1.0

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
      :smoothness,
      :source_tip_symbol_shape_id,
      :target_tip_symbol_shape_id,
      :source_tip_size,
      :target_tip_size
    ])
    # |> validate_required([:stroke_width, :stroke_color, :stroke_join, :stroke_cap, :stroke_dash_array, :source_tip, :target_tip, :smoothness])
    |> unique_constraint(:element_connection_id)
  end

  defmodule Snapshotter do
    alias RenewCollab.Style.EdgeStyle
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :edge_styles
    def schema(), do: EdgeStyle

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: e in assoc(l, :edge),
        join: s in assoc(e, :style),
        select: %{
          id: s.id,
          stroke_width: s.stroke_width,
          stroke_color: s.stroke_color,
          stroke_join: s.stroke_join,
          stroke_cap: s.stroke_cap,
          stroke_dash_array: s.stroke_dash_array,
          smoothness: s.smoothness,
          source_tip_symbol_shape_id: s.source_tip_symbol_shape_id,
          target_tip_symbol_shape_id: s.target_tip_symbol_shape_id,
          source_tip_size: s.source_tip_size,
          target_tip_size: s.target_tip_size,
          edge_id: s.edge_id,
          inserted_at: s.inserted_at,
          updated_at: s.updated_at
        }
      )
    end
  end
end
