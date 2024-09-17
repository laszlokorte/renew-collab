defmodule RenewCollab.Repo.Migrations.CreateShapePathStepArc do
  use Ecto.Migration

  def change do
    create table(:shape_path_step_arc, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :angle, :float, null: false, default: 0
      add :sweep, :boolean, default: false, null: false
      add :large, :boolean, default: false, null: false

      add :rx_value, :float, null: false
      add :rx_unit, :string, null: false, default: "width"
      add :rx_offset_operation, :string, null: false, default: "sum"
      add :rx_offset_value_static, :float, null: false, default: 0
      add :rx_offset_dynamic_value, :float, null: false, default: 0
      add :rx_offset_dynamic_unit, :string, default: "min"

      add :ry_value, :float, null: false
      add :ry_unit, :string, null: false, default: "height"
      add :ry_offset_operation, :string, null: false, default: "sum"
      add :ry_offset_value_static, :float, null: false, default: 0
      add :ry_offset_dynamic_value, :float, null: false, default: 0
      add :ry_offset_dynamic_unit, :string, default: "min"

      add :path_step_id, references(:shape_path_step, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:shape_path_step_arc, [:path_step_id])
  end
end
