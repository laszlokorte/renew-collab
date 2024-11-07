defmodule RenewCollab.Repo.Migrations.SimplifyStyles do
  use Ecto.Migration

  def change do
    alter table(:layer_style) do
      remove :border_width, :float
      add :border_width, :float
    end

    alter table(:element_edge_style) do
      remove :stroke_width, :float
      add :stroke_width, :float

      remove :source_tip
      remove :target_tip
    end
  end
end
