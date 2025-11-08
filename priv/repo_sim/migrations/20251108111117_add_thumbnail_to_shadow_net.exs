defmodule RenewCollabSim.Repo.Migrations.AddThumbnailToShadowNet do
  use Ecto.Migration

  def change do
    alter table(:shadow_net) do
      add :thumbnail_json, :binary, null: true, default: nil
    end
  end
end
