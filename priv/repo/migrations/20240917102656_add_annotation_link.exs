defmodule RenewCollab.Repo.Migrations.AddAnnotationLink do
  use Ecto.Migration

  def change do
    create table(:annotation_link, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :layer_id, references(:layer, on_delete: :delete_all, type: :binary_id), null: false

      add :text_id, references(:element_text, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:annotation_link, [:text_id])
  end
end
