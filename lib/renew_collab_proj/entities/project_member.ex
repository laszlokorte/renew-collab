defmodule RenewCollabProj.Entites.ProjectMember do
  use Ecto.Schema
  import Ecto.Changeset

  @member_roles [:owner, :editor, :reader]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_member" do
    belongs_to :project, RenewCollabProj.Entites.Project
    belongs_to :account, RenewCollabAuth.Entites.Account

    field :role, Ecto.Enum, values: @member_roles

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:account_id, :role])
    |> validate_required([:project_id, :account_id, :role])
  end

  @doc false
  def changeset_creation(member, attrs) do
    member
    |> cast(attrs, [:account_id, :role])
    |> validate_required([:account_id, :role])
    |> dbg
  end

  def roles(), do: @member_roles
end
