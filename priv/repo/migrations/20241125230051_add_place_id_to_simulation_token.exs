defmodule RenewCollab.Repo.Migrations.AddPlaceIdToSimulationToken do
  use Ecto.Migration

  def change do
    alter table(:simulation_net_token) do
      add :place_id, :binary, null: false
    end
  end
end
