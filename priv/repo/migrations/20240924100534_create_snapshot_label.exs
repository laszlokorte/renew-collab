defmodule RenewCollab.Repo.Migrations.CreateSnapshotLabel do
  use Ecto.Migration

  def change do
    create table(:snapshot_label, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :snapshot_id, references(:snapshot, on_delete: :delete_all, type: :binary_id),
        null: false

      add :description, :string, null: false
    end

    create unique_index(:snapshot_label, [:snapshot_id])
  end
end
