defmodule RenewCollabAuth.Repo.Migrations.CreateAccountPasskey do
  use Ecto.Migration

  def change do
    create table(:account_passkey, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :account_id,
          references(:account,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :label, :string, null: false
      add :key_id, :binary, null: false
      add :public_key, :binary, null: false
      add :last_used_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:account_passkey, [:account_id])
    create unique_index(:account_passkey, [:key_id])
    create unique_index(:account_passkey, [:account_id, :label])
  end
end
