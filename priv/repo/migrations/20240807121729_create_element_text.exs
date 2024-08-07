defmodule RenewCollab.Repo.Migrations.CreateElementText do
  use Ecto.Migration

  def change do
    create table(:element_text, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text
      add :element_id, references(:element, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_text, [:element_id])
  end
end
