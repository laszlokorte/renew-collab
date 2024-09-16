defmodule RenewCollab.Repo.Migrations.AddRichFlagToTextStyle do
  use Ecto.Migration

  def change do
    alter table(:element_text_style) do
      add :rich,
          :boolean,
          null: false,
          default: false
    end
  end
end
