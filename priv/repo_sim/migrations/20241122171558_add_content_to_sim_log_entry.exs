defmodule RenewCollab.Repo.Migrations.AddContentToSimLogEntry do
  use Ecto.Migration

  def change do
    alter table(:simulation_log_entry) do
      add :content, :string
    end
  end
end
