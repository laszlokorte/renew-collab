defmodule RenewCollab.Repo.Migrations.CreateSnapshot do
  use Ecto.Migration

  def change do
    create table(:snapshot, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :document_id, references(:document, on_delete: :delete_all, type: :binary_id),
        null: false

      add :content, :binary

      timestamps(type: :utc_datetime)
    end
  end
end
