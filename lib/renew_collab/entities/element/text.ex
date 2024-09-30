defmodule RenewCollab.Element.Text do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "element_text" do
    field :position_x, :float
    field :position_y, :float
    field :body, :string, default: ""
    belongs_to :layer, RenewCollab.Hierarchy.Layer
    has_one :style, RenewCollab.Style.TextStyle, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(element_text, attrs) do
    element_text
    |> cast(attrs, [:position_x, :position_y, :body])
    |> cast_assoc(:style)
    |> validate_required([:position_x, :position_y])
    |> unique_constraint(:element_id)
  end

  def change_position(element_text, attrs) do
    element_text
    |> cast(attrs, [
      :position_x,
      :position_y
    ])
  end

  defmodule Snapshotter do
    alias RenewCollab.Hierarchy.Layer
    alias RenewCollab.Element.Text
    @behaviour RenewCollab.Versioning.SnapshotterBehavior

    def storage_key(), do: :textes
    def schema(), do: Text

    def query(document_id) do
      import Ecto.Query, warn: false

      from(l in Layer,
        where: l.document_id == ^document_id,
        join: t in assoc(l, :text),
        select: %{
          id: t.id,
          layer_id: t.layer_id,
          position_x: t.position_x,
          position_y: t.position_y,
          body: t.body,
          inserted_at: t.inserted_at,
          updated_at: t.updated_at
        }
      )
    end
  end
end
