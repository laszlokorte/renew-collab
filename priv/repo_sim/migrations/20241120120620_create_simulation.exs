defmodule RenewCollab.Repo.Migrations.CreateSimulation do
  use Ecto.Migration

  def change do
    create table(:shadow_net_system, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :compiled, :binary, null: false
      add :main_net_name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:shadow_net, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :shadow_net_system_id,
          references(:shadow_net_system,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:simulation, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :shadow_net_system_id,
          references(:shadow_net_system,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      timestamps(type: :utc_datetime)
    end

    create table(:simulation_log_entry, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :simulation_id,
          references(:simulation,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      timestamps(type: :utc_datetime)
    end
  end
end
