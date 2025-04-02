defmodule RenewCollab.Repo.Migrations.AddStyleToSyntaxAutoNode do
  use Ecto.Migration

  def change do
    alter table(:syntax_edge_auto_target) do
      add :style, :map, null: true, default: nil
    end
  end
end
