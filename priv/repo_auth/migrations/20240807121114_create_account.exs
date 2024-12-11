defmodule RenewCollab.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:account, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :email, :string, null: false
      add :password, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:account, [:email])
  end
end
