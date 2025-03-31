defmodule RenewCollab.Repo.Migrations.AddSyntaxToDocument do
  use Ecto.Migration

  def change do
    alter table(:document) do
      add :syntax_id, references(:syntax, on_delete: :nilify_all, type: :binary_id),
        null: true,
        default: nil
    end
  end
end
