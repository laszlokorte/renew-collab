defmodule RenewCollab.Repo.Migrations.CreateLatestSnapshot do
  use Ecto.Migration

  def change do
    create table(:latest_snapshot, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :document_id, references(:document, on_delete: :delete_all, type: :binary_id),
        null: false

      add :snapshot_id, references(:snapshot, on_delete: :delete_all, type: :binary_id),
        null: false
    end

    create unique_index(:latest_snapshot, [:document_id])
  end
end
