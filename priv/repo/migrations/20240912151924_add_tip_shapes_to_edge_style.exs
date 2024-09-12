defmodule RenewCollab.Repo.Migrations.AddTipShapesToEdgeStyle do
  use Ecto.Migration

  def change do
    alter table(:element_edge_style) do
      add :source_tip_symbol_shape_id,
          references(:symbol_shape, on_delete: :nilify_all, type: :binary_id),
          null: true

      add :target_tip_symbol_shape_id,
          references(:symbol_shape, on_delete: :nilify_all, type: :binary_id),
          null: true
    end
  end
end
