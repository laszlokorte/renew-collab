defmodule RenewCollab.Syntax.SyntaxType do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "syntax" do
    field :name, :string

    has_many :edge_whitelists, RenewCollab.Syntax.SyntaxEdgeWhitelist, foreign_key: :syntax_id
    has_many :edge_auto_targets, RenewCollab.Syntax.SyntaxEdgeAutoTarget, foreign_key: :syntax_id
    has_one :default, RenewCollab.Syntax.SyntaxDefault, foreign_key: :syntax_id
  end

  @doc false
  def changeset(syntax_type, attrs) do
    syntax_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_assoc(:edge_whitelists)
    |> cast_assoc(:edge_auto_targets)
    |> cast_assoc(:default)
    |> unique_constraint(:name)
  end
end
