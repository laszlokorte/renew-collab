defmodule RenewCollab.Repo.Migrations.CreateDocument do
  use Ecto.Migration

  def change do
    create table(:document, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :kind, :string

      timestamps(type: :utc_datetime)
    end
  end
end
