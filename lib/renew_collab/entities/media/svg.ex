defmodule RenewCollab.Media.Svg do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "media_svg" do
    field :width, :float
    field :height, :float
    field :xml, :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(svg, attrs) do
    svg
    |> cast(attrs, [
      :width,
      :height,
      :xml
    ])
    |> validate_required([:width, :height, :xml])
  end
end
