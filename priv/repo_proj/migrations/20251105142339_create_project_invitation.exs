defmodule RenewCollabProj.Repo.Migrations.CreateProjectInvitation do
  use Ecto.Migration

  def change do
    create table(:project_invitation, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :project_id,
          references(:project,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :account_id, :binary_id, null: true
      add :email, :string, null: false
      add :role, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:project_invitation, [:project_id, :email])
    create unique_index(:project_invitation, [:project_id, :account_id])
  end
end
