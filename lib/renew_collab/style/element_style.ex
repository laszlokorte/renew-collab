defmodule RenewCollab.Style.ElementStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_style" do
    field :opacity, :float
    field :background_color, :string
    field :border_color, :string
    field :border_width, :string
    belongs_to :element, RenewCollab.Element.Element

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_style, attrs) do
    element_style
    |> cast(attrs, [:opacity, :background_color, :border_color, :border_width, :border_width])
    |> validate_required([:opacity, :background_color, :border_color, :border_width, :border_width])
    |> unique_constraint(:element_id)
  end
end
