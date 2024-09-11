defmodule RenewCollab.Repo.Migrations.AddShapeToElementBox do
  use Ecto.Migration

  def change do
    alter table(:element_box) do
      add :symbol_shape_id, references(:symbol_shape, on_delete: :nilify_all, type: :binary_id),
        null: true
    end
  end
end
