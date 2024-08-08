defmodule RenewCollab.Repo.Migrations.CreateElementConnectionSourceBond do
  use Ecto.Migration

  def change do
    create table(:element_connection_source_bond, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :element_connection_id, references(:element_connection, on_delete: :delete_all, type: :binary_id), null: false
      add :source_socket_id, references(:element_socket, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_connection_source_bond, [:element_connection_id])
    create index(:element_connection_source_bond, [:source_socket_id])
  end
end
