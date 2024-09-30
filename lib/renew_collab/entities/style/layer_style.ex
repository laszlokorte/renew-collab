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

  defmodule Snapshotter do
    alias RenewCollab.Style.LayerStyle
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :layer_styles
    def schema(), do: LayerStyle

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: s in assoc(l, :style),
        select: %{
          id: s.id,
          opacity: s.opacity,
          background_color: s.background_color,
          border_color: s.border_color,
          border_width: s.border_width,
          border_dash_array: s.border_dash_array,
          layer_id: s.layer_id,
          inserted_at: s.inserted_at,
          updated_at: s.updated_at
        }
      )
    end
  end
end
