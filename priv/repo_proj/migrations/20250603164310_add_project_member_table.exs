defmodule RenewCollabProj.Repo.Migrations.AddProjectMemberTable do
  use Ecto.Migration

  def change do
    create table(:project_member, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :project_id,
          references(:project,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :account_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end
    
  end
end
