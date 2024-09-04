defmodule RenewCollab.Repo.Migrations.CreateEdgeStyle do
  use Ecto.Migration

  def change do
    create table(:element_edge_style, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :stroke_width, :string
      add :stroke_color, :string
      add :stroke_joint, :string
      add :stroke_cap, :string
      add :stroke_dash_array, :string
      add :source_tip, :string
      add :target_tip, :string
      add :smoothness, :string

      add :edge_id,
          references(:element_edge, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_edge_style, [:edge_id])
  end
end
