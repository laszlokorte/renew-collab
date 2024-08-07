defmodule RenewCollab.Repo.Migrations.CreateElementSocket do
  use Ecto.Migration

  def change do
    create table(:element_socket, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :kind, :string
      add :element_id, references(:element, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_socket, [:element_id, :name])
  end
end
