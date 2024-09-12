defmodule RenewCollab.Repo.Migrations.CreateShape do
  use Ecto.Migration

  def change do
    create table(:symbol_shape, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:symbol_shape, [:name])
  end
end