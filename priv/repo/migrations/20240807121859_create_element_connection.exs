defmodule RenewCollab.Repo.Migrations.CreateElementConnection do
  use Ecto.Migration

  def change do
    create table(:element_connection, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :source_x, :float
      add :source_y, :float
      add :target_x, :float
      add :target_y, :float
      add :element_id, references(:element, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_connection, [:element_id])
  end
end
