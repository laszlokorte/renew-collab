defmodule RenewCollab.Repo.Migrations.AddSeparateStyleOpacities do
  use Ecto.Migration

  def change do
    alter table(:layer_style) do
      add :background_opacity, :float, default: 1.0
      add :border_opacity, :float, default: 1.0
    end

    alter table(:element_edge_style) do
      add :stroke_opacity, :float, default: 1.0
    end

    alter table(:element_text_style) do
      add :opacity, :float, default: 1.0
      add :background_color, :string
      add :background_opacity, :float, default: 1.0
    end
  end
end
