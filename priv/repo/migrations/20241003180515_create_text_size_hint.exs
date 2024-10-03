defmodule RenewCollab.Repo.Migrations.CreateTextSizeHint do
  use Ecto.Migration

  def change do
    create table(:text_size_hint, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :text_id, references(:element_text, on_delete: :delete_all, type: :binary_id),
        null: false

      add :position_x, :float, null: false
      add :position_y, :float, null: false
      add :width, :float, null: false
      add :height, :float, null: false
    end

    create unique_index(:text_size_hint, [:text_id])
  end
end
