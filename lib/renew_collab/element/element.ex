defmodule RenewCollab.Element.Element do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element" do
    field :z_index, :integer
    field :position_x, :float
    field :position_y, :float
    belongs_to :document, RenewCollab.Document.Document
    has_one :box, RenewCollab.Element.ElementBox
    has_one :text, RenewCollab.Element.ElementText
    has_one :connection, RenewCollab.Connection.ElementConnection
    has_one :style, RenewCollab.Style.ElementStyle
    has_many :sockets, RenewCollab.Connection.ElementSocket

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:z_index, :position_x, :position_y])
    |> cast_assoc(:box)
    |> cast_assoc(:text)
    |> cast_assoc(:connection)
    |> cast_assoc(:style)
    |> cast_assoc(:sockets)
    |> validate_required([:z_index, :position_x, :position_y])
  end
end
