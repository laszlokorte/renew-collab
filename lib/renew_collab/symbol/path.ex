defmodule RenewCollab.Symbol.Path do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shape_path" do
    field :sort, :integer
    field :fill_color, :string
    field :stroke_color, :string
    belongs_to :shape, RenewCollab.Symbol.Shape
    has_many :segments, RenewCollab.Symbol.PathSegment, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path, attrs) do
    path
    |> cast(attrs, [:fill_color, :stroke_color, :sort])
    |> cast_assoc(:segments)
    |> validate_required([:fill_color, :stroke_color, :sort])
  end
end
