defmodule RenewCollab.Repo.Migrations.AddSimulationNetInstance do
  use Ecto.Migration

  def change do
    create table(:simulation_net_instance, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :simulation_id,
          references(:simulation,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :label, :string, null: false
    end

    create unique_index(:simulation_net_instance, [:simulation_id, :label])
  end
end
