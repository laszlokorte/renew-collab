defmodule RenewCollab.Hierarchy.Layer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "layer" do
    field :z_index, :integer
    field :semantic_tag, :string
    field :hidden, :boolean, default: false
    belongs_to :document, RenewCollab.Document.Document
    has_one :box, RenewCollab.Element.Box, on_delete: :delete_all
    has_one :text, RenewCollab.Element.Text, on_delete: :delete_all
    has_one :edge, RenewCollab.Element.Edge, on_delete: :delete_all
    has_one :style, RenewCollab.Style.LayerStyle, on_delete: :delete_all
    has_many :sockets, RenewCollab.Element.Socket, on_delete: :delete_all

    has_one :direct_parent, RenewCollab.Hierarchy.LayerParenthood,
      foreign_key: :descendant_id,
      where: [depth: 1]

    has_one :ancestors, RenewCollab.Hierarchy.LayerParenthood,
      foreign_key: :descendant_id,
      where: [depth: {:>, 0}],
      preload_order: [asc: :depth]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(layer, attrs) do
    layer
    |> cast(attrs, [:id, :z_index, :semantic_tag, :hidden])
    |> cast_assoc(:box)
    |> cast_assoc(:text)
    |> cast_assoc(:edge)
    |> cast_assoc(:style)
    |> cast_assoc(:sockets)
    |> validate_required([:z_index])
  end
end
