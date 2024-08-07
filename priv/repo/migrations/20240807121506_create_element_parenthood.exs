defmodule RenewCollab.Repo.Migrations.CreateElementParenthood do
  use Ecto.Migration

  def change do
    create table(:element_parenthood, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :depth, :integer
      add :ancestor_id, references(:element, on_delete: :delete_all, type: :binary_id)
      add :descendant_id, references(:element, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:element_parenthood, [:ancestor_id])
    create index(:element_parenthood, [:descendant_id])
    create unique_index(:element_parenthood, [:descendant_id, :ancestor_id])
  end
end
