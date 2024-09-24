defmodule RenewCollab.Repo.Migrations.AddUniqueIndexToSnapshots do
  use Ecto.Migration

  def change do
    create unique_index(:snapshot, [:document_id, :inserted_at])
  end
end
