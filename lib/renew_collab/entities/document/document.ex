defmodule RenewCollab.Document.Document do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "document" do
    field :name, :string
    field :kind, :string

    has_many :layers, RenewCollab.Hierarchy.Layer,
      on_delete: :delete_all,
      preload_order: [asc: :z_index]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:name, :kind])
    |> cast_assoc(:layers)
    |> validate_required([:name, :kind])
  end

  @doc false
  def changeset_meta(document, attrs) do
    document
    |> cast(attrs, [:name, :kind])
  end
end
