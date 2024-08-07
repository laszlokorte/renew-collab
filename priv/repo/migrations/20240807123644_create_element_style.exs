defmodule RenewCollab.Repo.Migrations.CreateElementStyle do
  use Ecto.Migration

  def change do
    create table(:element_style, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :opacity, :float
      add :background_color, :string
      add :border_color, :string
      add :border_width, :string
      add :border_width, :string
      add :element_id, references(:element, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_style, [:element_id])
  end
end
