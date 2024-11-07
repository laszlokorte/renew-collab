defmodule RenewCollab.Repo.Migrations.CreateWaypointTangents do
  use Ecto.Migration

  def change do
    create table(:waypoint_tangent, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :position_x, :float, null: false
      add :position_y, :float, null: false
      add :incoming, :boolean, null: false

      add :waypoint_id,
          references(:waypoint, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:waypoint_tangent, [:waypoint_id, :incoming])
  end
end
