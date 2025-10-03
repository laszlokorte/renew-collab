defmodule RenewCollabProj.Repo.Migrations.AddProjectShadowNetSystem do
  use Ecto.Migration

  def change do
    create table(:project_shadow_net_system, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :project_id,
          references(:project,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :shadow_net_system_id, :binary_id, null: false


      timestamps(type: :utc_datetime)
    end

    create unique_index(:project_shadow_net_system, [:shadow_net_system_id])
  end
end
