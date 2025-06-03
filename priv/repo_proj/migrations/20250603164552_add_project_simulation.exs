defmodule RenewCollabProj.Repo.Migrations.AddProjectSimulation do
  use Ecto.Migration

  def change do
    create table(:project_simulation, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :project_id,
          references(:project,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :simulation_id,
          references(:simulation,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:project_simulation, [:simulation_id])
  end
end
