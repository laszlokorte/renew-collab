defmodule RenewCollab.Renew.ElementConnectionStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_connection_style" do
    field :stroke_width, :string
    field :stroke_color, :string
    field :stroke_joint, :string
    field :stroke_cap, :string
    field :stroke_dash_array, :string
    field :source_tip, :string
    field :target_tip, :string
    field :smoothness, :string
    field :element_connection_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_connection_style, attrs) do
    element_connection_style
    |> cast(attrs, [:stroke_width, :stroke_color, :stroke_joint, :stroke_cap, :stroke_dash_array, :source_tip, :target_tip, :smoothness])
    |> validate_required([:stroke_width, :stroke_color, :stroke_joint, :stroke_cap, :stroke_dash_array, :source_tip, :target_tip, :smoothness])
    |> unique_constraint(:element_connection_id)
  end
end
