defmodule RenewCollabProj.Entities.ProjectMember do
  use Ecto.Schema
  import Ecto.Changeset

  @member_roles [:owner, :editor, :reader]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_member" do
    belongs_to :project, RenewCollabProj.Entities.Project
    belongs_to :account, RenewCollabAuth.Entities.Account

    field :role, Ecto.Enum, values: @member_roles

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:account_id, :role])
    |> validate_required([:project_id, :account_id, :role])
    |> unique_constraint([:project_id, :account_id])
  end

  @doc false
  def changeset_creation(member, attrs) do
    member
    |> cast(attrs, [:account_id, :role])
    |> validate_required([:account_id, :role])
    |> unique_constraint([:project_id, :account_id])

    # |> dbg
  end

  defmacro roles_list, do: quote(do: unquote(@member_roles))
  def roles(), do: @member_roles

  def weaker_roles(:owner), do: [:editor, :reader]
  def weaker_roles(:editor), do: [:reader]
  def weaker_roles(_), do: []

  def parse_role("owner"), do: :owner
  def parse_role("editor"), do: :editor
  def parse_role("reader"), do: :reader
end
