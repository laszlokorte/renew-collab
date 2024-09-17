defmodule RenewCollab.Repo.Migrations.CreateElementConnectionBond do
  use Ecto.Migration

  def change do
    create table(:connection_bond, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :kind, :string, null: false
      add :name, :string, null: false

      add :element_edge_id, references(:element_edge, on_delete: :delete_all, type: :binary_id),
        null: false

      add :layer_id, references(:layer, on_delete: :delete_all, type: :binary_id), null: false

      add :socket_id,
          references(:socket, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:connection_bond, [:element_edge_id])
    create index(:connection_bond, [:socket_id])
  end
end
