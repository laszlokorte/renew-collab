defmodule RenewCollab.Repo.Migrations.AddIconToPrimitive do
  use Ecto.Migration

  def change do
    alter table(:predefined_primitive) do
      add :icon, :string, null: false, default: ""
      add :data, :map, null: false
      remove :content
    end
  end
end
