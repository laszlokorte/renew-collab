defmodule RenewCollab.Repo.Migrations.CreateShapePathStepVertical do
  use Ecto.Migration

  def change do
    create table(:shape_path_step_vertical, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :y_value, :float, null: false
      add :y_unit, :string, null: "width"
      add :y_offset_operation, :string, null: false, default: "add"
      add :y_offset_value_static, :float, null: false, default: 0
      add :y_offset_dynamic_value, :float, null: false, default: 0
      add :y_offset_dynamic_unit, :string, default: "min"

      add :path_step_id, references(:shape_path_step, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:shape_path_step_vertical, [:path_step_id])
  end
end
