defmodule RenewCollab.Repo.Migrations.CreateHyperlink do
  use Ecto.Migration

  def change do
    create table(:hyperlink, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :source_layer_id, references(:layer, on_delete: :delete_all, type: :binary_id),
        null: false

      add :target_layer_id, references(:layer, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:hyperlink, [:source_layer_id])
  end
end
