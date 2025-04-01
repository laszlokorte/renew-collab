defmodule RenewCollab.Syntax.SyntaxDefault do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "syntax_default" do
    belongs_to :syntax_type, RenewCollab.Syntax.SyntaxType, foreign_key: :syntax_id
  end

  @doc false
  def changeset(def, attrs) do
    def
    |> cast(attrs, [])
  end
end
