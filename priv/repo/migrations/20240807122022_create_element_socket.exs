defmodule RenewCollab.Repo.Migrations.CreateElementSocket do
  use Ecto.Migration

  def change do
    create table(:element_socket, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string, null: false
      add :kind, :string, null: false
      add :element_id, references(:element, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_socket, [:element_id, :name])
  end
end
