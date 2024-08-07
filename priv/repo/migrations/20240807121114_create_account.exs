defmodule RenewCollab.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:account, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :password, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:account, [:email])
  end
end
