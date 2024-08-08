defmodule RenewCollab.Repo.Migrations.CreateElementParenthood do
  use Ecto.Migration

  def change do
    create table(:element_parenthood, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :document_id, references(:document, on_delete: :delete_all, type: :binary_id), null: false
      add :ancestor_id, references(:element, on_delete: :delete_all, type: :binary_id), null: false
      add :descendant_id, references(:element, on_delete: :delete_all, type: :binary_id), null: false
      add :depth, :integer, null: false
    end

    create index(:element_parenthood, [:ancestor_id])
    create index(:element_parenthood, [:descendant_id])
    create unique_index(:element_parenthood, [:descendant_id, :ancestor_id])
  end
end
