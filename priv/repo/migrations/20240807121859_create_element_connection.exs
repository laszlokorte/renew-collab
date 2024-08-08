defmodule RenewCollab.Repo.Migrations.CreateElementConnection do
  use Ecto.Migration

  def change do
    create table(:element_connection, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :source_x, :float, null: false
      add :source_y, :float, null: false
      add :target_x, :float, null: false
      add :target_y, :float, null: false
      add :element_id, references(:element, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_connection, [:element_id])
  end
end
