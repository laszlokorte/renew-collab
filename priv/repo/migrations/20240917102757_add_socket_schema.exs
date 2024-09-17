defmodule RenewCollab.Repo.Migrations.AddSocketSchema do
  use Ecto.Migration

  def change do
    create table(:socket_schema, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :name, :string, null: false
      add :trim, :string, null: true

      timestamps(type: :utc_datetime)
    end

    create table(:socket, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :socket_schema_id, references(:socket_schema, on_delete: :delete_all, type: :binary_id),
        null: false

      add :y_value, :float, null: false
      add :y_unit, :string, null: false, default: "height"
      add :y_offset_operation, :string, null: false, default: "sum"
      add :y_offset_value_static, :float, null: false, default: 0
      add :y_offset_dynamic_value, :float, null: false, default: 0
      add :y_offset_dynamic_unit, :string, default: "min"

      add :x_value, :float, null: false
      add :x_unit, :string, null: false, default: "width"
      add :x_offset_operation, :string, null: false, default: "sum"
      add :x_offset_value_static, :float, null: false, default: 0
      add :x_offset_dynamic_value, :float, null: false, default: 0
      add :x_offset_dynamic_unit, :string, default: "min"

      timestamps(type: :utc_datetime)
    end
  end
end
