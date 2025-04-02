defmodule RenewCollab.Repo.Migrations.MakeSyntaxNameUnique do
  use Ecto.Migration

  def change do
    create unique_index(:syntax, [
             :name
           ])
  end
end
