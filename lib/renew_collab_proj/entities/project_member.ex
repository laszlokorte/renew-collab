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
end
