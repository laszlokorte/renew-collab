defmodule RenewCollabProj.Repo.Migrations.AddRoleToProjectMember do
  use Ecto.Migration

  def change do

    alter table(:project_member) do
      add :role, :string, null: false, default: "editor"
    end
  end
end
