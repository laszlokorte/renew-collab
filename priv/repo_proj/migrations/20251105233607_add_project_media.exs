defmodule RenewCollabProj.Repo.Migrations.AddProjectMedia do
  use Ecto.Migration

  def change do
    create table(:project_media, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :project_id,
          references(:project,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :media_id, :binary_id, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:project_media, [:media_id])
  end
end
