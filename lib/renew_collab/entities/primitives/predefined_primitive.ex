defmodule RenewCollab.Primitives.PredefinedPrimitive do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "predefined_primitive" do
    field :name, :string

    field :data, :map
    field :icon, :string

    belongs_to :group, RenewCollab.Primitives.PredefinedPrimitiveGroup,
      foreign_key: :predefined_primitive_group_id
  end

  @doc false
  def changeset(primitive, attrs) do
    primitive
    |> cast(attrs, [:name, :data, :icon])
    |> validate_required([:name, :data, :icon])
    |> unique_constraint(:name)
  end
end
