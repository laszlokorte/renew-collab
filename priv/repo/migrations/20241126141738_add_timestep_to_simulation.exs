defmodule RenewCollab.Repo.Migrations.AddTimestepToSimulation do
  use Ecto.Migration

  def change do
    alter table(:simulation) do
      add :timestep, :integer, null: false, default: 0
    end
  end
end
