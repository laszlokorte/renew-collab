defmodule RenewCollab.Repo.Migrations.AddRenewTypeToElementText do
  use Ecto.Migration

  def change do
    alter table(:element_text) do
      add :renew_type, :integer
    end
  end
end
