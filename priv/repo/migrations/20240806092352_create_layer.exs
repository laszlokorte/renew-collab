defmodule RenewCollab.Repo.Migrations.CreateLayer do
  use Ecto.Migration

  def change do
    create table(:layer, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :z_index, :integer, null: false
      add :hidden, :boolean, null: false, default: false

      add :semantic_tag, :string

      add :document_id, references(:document, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:layer, [:document_id])
  end
end
