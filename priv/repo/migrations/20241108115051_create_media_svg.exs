defmodule RenewCollab.Repo.Migrations.CreateMediaSvg do
  use Ecto.Migration

  def change do
    create table(:media_svg, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :width, :float, null: false
      add :height, :float, null: false
      add :xml, :text, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
