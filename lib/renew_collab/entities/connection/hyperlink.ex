defmodule RenewCollab.Connection.Hyperlink do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hyperlink" do
    belongs_to :source_layer, RenewCollab.Hierarchy.Layer
    belongs_to :target_layer, RenewCollab.Hierarchy.Layer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hyperlink, attrs) do
    hyperlink
    |> cast(attrs, [:source_layer_id, :target_layer_id])
    |> validate_required([:source_layer_id, :target_layer_id])
    |> unique_constraint(:source_layer_id)
  end

  @doc false
  def nested_changeset(hyperlink, attrs) do
    hyperlink
    |> cast(attrs, [:target_layer_id])
    |> unique_constraint(:source_layer_id)
  end

  defmodule Snapshotter do
    alias RenewCollab.Connection.Hyperlink
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :hyperlinks
    def schema(), do: Hyperlink

    def query(document_id) do
      import Ecto.Query, warn: false

      from(h in Hyperlink,
        join: s in assoc(h, :source_layer),
        join: t in assoc(h, :target_layer),
        where: s.document_id == ^document_id and t.document_id == ^document_id,
        select: %{
          id: h.id,
          source_layer_id: h.source_layer_id,
          target_layer_id: h.target_layer_id,
          inserted_at: h.inserted_at,
          updated_at: h.updated_at
        }
      )
    end
  end
end
