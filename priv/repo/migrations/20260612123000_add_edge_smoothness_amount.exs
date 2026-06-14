defmodule RenewCollab.Repo.Migrations.AddEdgeSmoothnessAmount do
  use Ecto.Migration

  def change do
    alter table(:element_edge_style) do
      add :smoothness_amount, :float, default: 50.0
    end
  end
end
