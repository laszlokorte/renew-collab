defmodule RenewCollab.Repo.Migrations.AddTargetLocationToLayerStyle do
  use Ecto.Migration

  def change do
    alter table(:layer_style) do
      add :target_location, :string
    end
  end
end
