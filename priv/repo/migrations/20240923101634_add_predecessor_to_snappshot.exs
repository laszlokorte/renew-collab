defmodule RenewCollab.Repo.Migrations.AddPredecessorToSnappshot do
  use Ecto.Migration

  def change do
    alter table(:snapshot) do
      add :predecessor_id, references(:snapshot, on_delete: :delete_all, type: :binary_id),
        null: false
    end
  end
end
