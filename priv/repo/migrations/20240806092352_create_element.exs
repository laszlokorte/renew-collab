defmodule RenewCollab.Repo.Migrations.CreateElement do
  use Ecto.Migration

  def change do
    create table(:element, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :z_index, :integer
      add :position_x, :float
      add :position_y, :float
      add :document_id, references(:document, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:element, [:document_id])
  end
end
