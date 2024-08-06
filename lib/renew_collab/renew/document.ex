defmodule RenewCollab.Renew.Document do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "document" do
    field :name, :string
    field :kind, :string
    has_many :elements, RenewCollab.Renew.Element

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:name, :kind])
    |> validate_required([:name, :kind])
  end
end
