defmodule RenewCollabAuth.Repo.Migrations.CreateAccountPasswordResetRequest do
  use Ecto.Migration

  def change do
    create table(:account_password_reset_request, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :account_id,
          references(:account,
            on_delete: :delete_all,
            on_update: :update_all,
            type: :binary_id
          ),
          null: false

      add :been_used, :boolean, null: false, default: false

      timestamps(type: :utc_datetime)
    end
  end
end
