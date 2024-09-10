defmodule RenewCollab.Symbol.PathStep do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shape_path_step" do
    field :sort, :integer
    field :relative, :boolean
    belongs_to :path_segment, RenewCollab.Symbol.PathSegment
    has_one :arc, RenewCollab.Symbol.PathStepArc, on_delete: :delete_all
    has_one :vertical, RenewCollab.Symbol.PathStepVertical, on_delete: :delete_all
    has_one :horizontal, RenewCollab.Symbol.PathStepHorizontal, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(path_step, attrs) do
    path_step
    |> cast(attrs, [:sort, :relative])
    |> cast_assoc(:arc)
    |> cast_assoc(:vertical)
    |> cast_assoc(:horizontal)
    |> validate_required([:sort, :relative])
  end
end
