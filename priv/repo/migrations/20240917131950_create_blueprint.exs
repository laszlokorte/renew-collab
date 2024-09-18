defmodule RenewCollab.Repo.Migrations.CreateBlueprint do
  use Ecto.Migration

  def change do
    create table(:blueprint, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :document_id, references(:document, on_delete: :delete_all, type: :binary_id),
        null: false

      add :origin_x, :float, null: false, default: 0.0
      add :origin_y, :float, null: false, default: 0.0

      timestamps(type: :utc_datetime)
    end
  end
end
