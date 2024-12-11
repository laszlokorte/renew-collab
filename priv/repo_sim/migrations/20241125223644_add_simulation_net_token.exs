defmodule RenewCollab.Repo.Migrations.AddSimulationNetToken do
  use Ecto.Migration

  def change do
    create table(:simulation_net_token, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :simulation_id,
          references(:simulation,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :simulation_net_instance_id,
          references(:simulation_net_instance,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :value, :string, null: false
    end
  end
end
