defmodule RenewCollab.Repo.Migrations.CreateElementInterface do
  use Ecto.Migration

  def change do
    create table(:element_interface, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :layer_id, references(:layer, on_delete: :delete_all, type: :binary_id), null: false

      add :socket_schema_id, references(:socket_schema, on_delete: :delete_all, type: :binary_id),
        null: true

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_interface, [:layer_id])
  end
end
