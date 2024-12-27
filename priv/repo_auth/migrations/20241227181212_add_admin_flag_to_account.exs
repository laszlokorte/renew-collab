defmodule RenewCollabAuth.Repo.Migrations.AddAdminFlagToAccount do
  use Ecto.Migration

  def change do
    alter table(:account) do
      add :is_admin, :boolean, null: false, default: false
    end
  end
end
