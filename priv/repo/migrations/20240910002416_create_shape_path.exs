defmodule RenewCollab.Repo.Migrations.CreateShapePath do
  use Ecto.Migration

  def change do
    create table(:shape_path, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fill_color, :string
      add :stroke_color, :string
      add :sort, :integer, null: false
      add :shape_id, references(:symbol_shape, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:shape_path, [:shape_id])
  end
end
