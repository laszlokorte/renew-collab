defmodule RenewCollabProj.Entites.ProjectMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_member" do
    belongs_to :project, RenewCollabProj.Entites.Project
    belongs_to :account, RenewCollabAuth.Entites.Account

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:account_id])
    |> validate_required([:project_id, :account_id])
  end
end
