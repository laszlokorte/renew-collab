defmodule RenewCollab.Repo.Migrations.CreateElementEdge do
  use Ecto.Migration

  def change do
    create table(:element_edge, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :source_x, :float, null: false
      add :source_y, :float, null: false
      add :target_x, :float, null: false
      add :target_y, :float, null: false
      add :layer_id, references(:layer, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_edge, [:layer_id])
  end
end
