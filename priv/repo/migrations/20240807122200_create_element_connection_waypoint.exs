defmodule RenewCollab.Repo.Migrations.CreateElementConnectionWaypoint do
  use Ecto.Migration

  def change do
    create table(:element_connection_waypoint, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :position_x, :float, null: false
      add :position_y, :float, null: false
      add :sort, :integer, null: false
      add :element_connection_id, references(:element_connection, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:element_connection_waypoint, [:element_connection_id])
    create unique_index(:element_connection_waypoint, [:element_connection_id, :sort])
  end
end
