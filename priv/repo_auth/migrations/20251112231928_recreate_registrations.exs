defmodule RenewCollabAuth.Repo.Migrations.RecreateRegistrations do
  use Ecto.Migration

  def change do
    drop table(:registration)

    create table(:registration, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :email, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:registration, [:email])
  end
end
