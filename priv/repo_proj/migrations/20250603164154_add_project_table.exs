defmodule RenewCollabProj.Repo.Migrations.AddProjectTable do
  use Ecto.Migration

  def change do
    create table(:project, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
