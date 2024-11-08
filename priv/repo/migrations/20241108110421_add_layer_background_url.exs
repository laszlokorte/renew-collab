defmodule RenewCollab.Repo.Migrations.AddLayerBackgroundUrl do
  use Ecto.Migration

  def change do
    alter table(:layer_style) do
      add :background_url, :string
    end
  end
end
