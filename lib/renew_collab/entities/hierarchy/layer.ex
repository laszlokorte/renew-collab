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
    has_one :interface, RenewCollab.Element.Interface, on_delete: :delete_all

    has_many :layers_of_document,
      through: [:document, :layers],
      preload_order: [asc: :z_index]

    has_one :direct_parent_hood, RenewCollab.Hierarchy.LayerParenthood,
      foreign_key: :descendant_id,
      where: [depth: 1]

    has_many :direct_children_hoods, RenewCollab.Hierarchy.LayerParenthood,
      foreign_key: :ancestor_id,
      where: [depth: 1]

    has_one :direct_parent_layer, through: [:direct_parent_hood, :ancestor]

    has_many :direct_children_layers,
      through: [:direct_children_hoods, :descendant],
      preload_order: [asc: :z_index]

    # Does not work for top level
    has_many :direct_sibling_layers,
      through: [:direct_parent_hood, :siblings, :descendant],
      preload_order: [asc: :z_index]

    has_one :ancestors, RenewCollab.Hierarchy.LayerParenthood,
      foreign_key: :descendant_id,
      where: [depth: {:>, 0}],
      preload_order: [asc: :depth]

    has_many :incoming_links, RenewCollab.Connection.Hyperlink,
      on_delete: :delete_all,
      foreign_key: :target_layer_id

    has_one :outgoing_link, RenewCollab.Connection.Hyperlink,
      on_delete: :delete_all,
      foreign_key: :source_layer_id

    has_many :available_sockets, through: [:interface, :socket_schema, :sockets]
    has_many :attached_bonds, RenewCollab.Connection.Bond, on_delete: :delete_all
    has_many :attached_edges, through: [:attached_bonds, :element_edge]
    has_many :used_sockets, through: [:attached_bonds, :socket]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(layer, attrs) do
    layer
    |> cast(attrs, [:document_id, :id, :z_index, :semantic_tag, :hidden])
    |> cast_assoc(:box)
    |> cast_assoc(:text)
    |> cast_assoc(:edge)
    |> cast_assoc(:style)
    |> cast_assoc(:interface)
    |> cast_assoc(:outgoing_link, with: &RenewCollab.Connection.Hyperlink.nested_changeset/2)
    |> validate_required([:z_index])
  end

  defmodule Snapshotter do
    alias RenewCollab.Hierarchy.Layer
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :layers
    def schema(), do: Layer

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        select: %{
          id: l.id,
          z_index: l.z_index,
          semantic_tag: l.semantic_tag,
          hidden: l.hidden,
          document_id: l.document_id,
          inserted_at: l.inserted_at,
          updated_at: l.updated_at
        }
      )
    end
  end
end
