defmodule RenewCollab.Repo.Migrations.AddEdgeTipSize do
  use Ecto.Migration

  def change do
    alter table(:element_edge_style) do
      add :source_tip_size, :float, default: 1
      add :target_tip_size, :float, default: 1
    end
  end
end
