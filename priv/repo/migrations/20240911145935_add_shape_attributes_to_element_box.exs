defmodule RenewCollab.Repo.Migrations.AddShapeAttributesToElementBox do
  use Ecto.Migration

  def change do
    alter table(:element_box) do
      add :symbol_shape_attributes, :map, null: true
    end
  end
end
