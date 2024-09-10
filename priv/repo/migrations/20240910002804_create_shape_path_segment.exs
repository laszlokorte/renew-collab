defmodule RenewCollab.Repo.Migrations.CreateShapePathSegment do
  use Ecto.Migration

  def change do
    create table(:shape_path_segment, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :sort, :integer, null: false
      add :relative, :boolean, default: false, null: false
      add :x_value, :float, null: false
      add :x_unit, :string, null: "width"
      add :x_offset_operation, :string, null: false, default: "add"
      add :x_offset_value_static, :float, null: false, default: 0
      add :x_offset_dynamic_value, :float, null: false, default: 0
      add :x_offset_dynamic_unit, :string, default: "min"
      add :y_value, :float, null: false
      add :y_unit, :string, null: "height"
      add :y_offset_operation, :string, null: false, default: "add"
      add :y_offset_value_static, :float, null: false, default: 0
      add :y_offset_dynamic_value, :float, null: false, default: 0
      add :y_offset_dynamic_unit, :string, default: "min"
      add :path_id, references(:shape_path, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:shape_path_segment, [:path_id])
  end
end
