defmodule RenewCollab.Repo.Migrations.CreateShapePathStep do
  use Ecto.Migration

  def change do
    create table(:shape_path_step, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :sort, :integer, null: false
      add :relative, :boolean, default: false, null: false

      add :path_segment_id,
          references(:shape_path_segment, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:shape_path_step, [:path_segment_id])
  end
end
