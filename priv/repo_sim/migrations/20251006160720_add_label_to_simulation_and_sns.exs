defmodule RenewCollabSim.Repo.Migrations.AddLabelToSimulationAndSns do
  use Ecto.Migration

  def change do
    alter table(:shadow_net_system) do
      add :label, :string, null: true
    end

    alter table(:simulation) do
      add :label, :string, null: true
    end
  end
end
