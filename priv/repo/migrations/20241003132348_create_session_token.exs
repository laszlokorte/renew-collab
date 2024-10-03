defmodule RenewCollab.Repo.Migrations.CreateSessionToken do
  use Ecto.Migration

  def change do
    create table(:session_token) do
      add :account_id, references(:account, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:session_token, [:account_id])
    create unique_index(:session_token, [:context, :token])
  end
end
