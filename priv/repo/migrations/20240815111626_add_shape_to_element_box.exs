defmodule RenewCollab.Repo.Migrations.AddShapeToElementBox do
  use Ecto.Migration

  def change do
    alter table("element_box") do
      add :shape, :string
    end
  end
end
