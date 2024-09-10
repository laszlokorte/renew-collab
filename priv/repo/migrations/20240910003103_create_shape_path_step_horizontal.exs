defmodule RenewCollab.Repo.Migrations.CreateShapePathStepHorizontal do
  use Ecto.Migration

  def change do
    create table(:shape_path_step_horizontal, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :x_value, :float, null: false
      add :x_unit, :string, null: "width"
      add :x_offset_operation, :string, null: false, default: "sum"
      add :x_offset_value_static, :float, null: false, default: 0
      add :x_offset_dynamic_value, :float, null: false, default: 0
      add :x_offset_dynamic_unit, :string, default: "min"

      add :path_step_id, references(:shape_path_step, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:shape_path_step_horizontal, [:path_step_id])
  end
end
