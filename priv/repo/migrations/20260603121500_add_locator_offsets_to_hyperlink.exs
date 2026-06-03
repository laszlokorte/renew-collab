defmodule RenewCollab.Repo.Migrations.AddLocatorOffsetsToHyperlink do
  use Ecto.Migration

  def change do
    alter table(:hyperlink) do
      add :locator_offset_x, :integer
      add :locator_offset_y, :integer
    end
  end
end
