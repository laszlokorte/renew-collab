defmodule RenewCollab.Symbol.Shape do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "symbol_shape" do
    field :name, :string
    has_many :paths, RenewCollab.Symbol.Path, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:name])
    |> cast_assoc(:paths)
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
