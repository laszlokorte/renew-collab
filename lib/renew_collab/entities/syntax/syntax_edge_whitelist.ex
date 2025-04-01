defmodule RenewCollab.Syntax.SyntaxEdgeWhitelist do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "syntax_edge_whitelist" do
    belongs_to :syntax, RenewCollab.Syntax.SyntaxType, foreign_key: :syntax_id

    field :source_semantic_tag, :string
    field :target_semantic_tag, :string
    field :edge_semantic_tag, :string
  end

  @doc false
  def changeset(whitelist, attrs) do
    whitelist
    |> cast(attrs, [
      :syntax_id,
      :source_semantic_tag,
      :target_semantic_tag,
      :edge_semantic_tag
    ])
    |> unique_constraint([
      :syntax_id,
      :source_semantic_tag,
      :target_semantic_tag,
      :edge_semantic_tag
    ])
  end
end
