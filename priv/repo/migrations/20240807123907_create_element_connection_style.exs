defmodule RenewCollab.Repo.Migrations.CreateElementConnectionStyle do
  use Ecto.Migration

  def change do
    create table(:element_connection_style, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :stroke_width, :string
      add :stroke_color, :string
      add :stroke_joint, :string
      add :stroke_cap, :string
      add :stroke_dash_array, :string
      add :source_tip, :string
      add :target_tip, :string
      add :smoothness, :string
      add :element_connection_id, references(:element_connection, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_connection_style, [:element_connection_id])
  end
end
