defmodule RenewCollab.Syntax.SyntaxEdgeAutoTarget do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "syntax_edge_auto_target" do
    belongs_to :syntax_type, RenewCollab.Syntax.SyntaxType, foreign_key: :syntax_id

    belongs_to :source_socket, RenewCollab.Connection.Socket
    belongs_to :target_shape, RenewCollab.Symbol.Shape
    belongs_to :target_socket, RenewCollab.Connection.Socket
    belongs_to :edge_source_tip, RenewCollab.Symbol.Shape
    belongs_to :edge_target_tip, RenewCollab.Symbol.Shape

    field :source_semantic_tag, :string
    field :target_semantic_tag, :string
    field :edge_semantic_tag, :string
  end

  @doc false
  def changeset(auto_target, attrs) do
    auto_target
    |> cast(attrs, [
      :source_semantic_tag,
      :target_semantic_tag,
      :edge_semantic_tag,
      :source_socket_id,
      :target_shape_id,
      :target_socket_id,
      :edge_source_tip_id,
      :edge_target_tip_id
    ])
    |> validate_required([
      :source_semantic_tag,
      :target_semantic_tag,
      :edge_semantic_tag,
      :source_socket_id,
      :target_shape_id,
      :target_socket_id
    ])
  end
end
