defmodule RenewCollab.Primitives.PredefinedPrimitiveGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "predefined_primitive_group" do
    field :name, :string

    has_many :primitives, RenewCollab.Primitives.PredefinedPrimitive,
      foreign_key: :predefined_primitive_group_id
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> cast_assoc(:primitives)
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
