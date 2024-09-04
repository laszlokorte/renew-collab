defmodule RenewCollab.Repo.Migrations.CreateWaypoint do
  use Ecto.Migration

  def change do
    create table(:waypoint, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :position_x, :float, null: false
      add :position_y, :float, null: false
      add :sort, :integer, null: false

      add :edge_id,
          references(:element_edge, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:waypoint, [:edge_id])
    create unique_index(:waypoint, [:edge_id, :sort])
  end
end
