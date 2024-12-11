defmodule RenewCollab.Repo.Migrations.AddShadowNetIdToSimulationNetInstance do
  use Ecto.Migration

  def change do
    alter table(:simulation_net_instance) do
      add :shadow_net_system_id,
          references(:shadow_net_system,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :shadow_net_id,
          references(:shadow_net,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :integer_id, :integer, null: false
    end
  end
end
