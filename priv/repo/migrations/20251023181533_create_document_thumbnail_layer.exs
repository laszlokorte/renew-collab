defmodule RenewCollab.Repo.Migrations.CreateDocumentThumbnailLayer do
  use Ecto.Migration

  def change do
    create table(:document_thumbnail_layer, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :document_id, references(:document, on_delete: :delete_all, type: :binary_id),
        null: false

      add :layer_id, references(:layer, on_delete: :delete_all, type: :binary_id), null: false
    end

    create unique_index(:document_thumbnail_layer, [:document_id])
    create index(:document_thumbnail_layer, [:layer_id])
  end
end
