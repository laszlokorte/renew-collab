defmodule RenewCollab.Repo.Migrations.CreateElementTextStyle do
  use Ecto.Migration

  def change do
    create table(:element_text_style, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :alignment, :string
      add :font_size, :float
      add :font_family, :string
      add :bold, :boolean, default: false, null: false
      add :italic, :boolean, default: false, null: false
      add :underline, :boolean, default: false, null: false
      add :text_color, :string

      add :text_id, references(:element_text, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:element_text_style, [:text_id])
  end
end
