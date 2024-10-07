defmodule RenewCollab.Repo.Migrations.CreateSnapshotContent do
  use Ecto.Migration

  def change do
    create table(:snapshot_content, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :snapshot_id,
          references(:snapshot, on_delete: :delete_all, on_update: :update_all, type: :binary_id),
          null: false

      add :content, :binary
    end

    alter table(:snapshot) do
      remove :content
    end

    create unique_index(:snapshot_content, [:snapshot_id])
  end
end
