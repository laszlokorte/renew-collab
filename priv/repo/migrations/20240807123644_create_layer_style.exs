defmodule RenewCollab.Repo.Migrations.CreateLayerStyle do
  use Ecto.Migration

  def change do
    create table(:layer_style, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :opacity, :float
      add :background_color, :string
      add :border_color, :string
      add :border_width, :string
      add :layer_id, references(:layer, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:layer_style, [:layer_id])
  end
end
