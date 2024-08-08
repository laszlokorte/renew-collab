defmodule RenewCollab.Repo.Migrations.CreateElement do
  use Ecto.Migration

  def change do
    create table(:element, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :z_index, :integer, null: false
      add :position_x, :float, null: false
      add :position_y, :float, null: false
      add :document_id, references(:document, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:element, [:document_id])
  end
end
