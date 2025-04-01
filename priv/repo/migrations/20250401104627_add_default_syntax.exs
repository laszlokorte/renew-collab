defmodule RenewCollab.Repo.Migrations.AddDefaultSyntax do
  use Ecto.Migration

  def change do
    create table(:syntax_default, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :syntax_id, references(:syntax, on_delete: :delete_all, type: :binary_id), null: false
    end
  end
end
