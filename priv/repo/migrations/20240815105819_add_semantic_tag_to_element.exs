defmodule RenewCollab.Repo.Migrations.AddSemanticTagToElement do
  use Ecto.Migration

  def change do
    alter table("element") do
      add :semantic_tag, :string
    end
  end
end
