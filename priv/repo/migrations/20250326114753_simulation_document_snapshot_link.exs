defmodule RenewCollabSim.Repo.Migrations.AddDocumentSnapshotSimulation do
  use Ecto.Migration

  def change do
    create table(:document_snapshot_simulation, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :snapshot_id,
          references(:snapshot,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :document_id,
          references(:document,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :simulation_id, :binary_id, null: false
      timestamps(type: :utc_datetime)
    end
  end
end
