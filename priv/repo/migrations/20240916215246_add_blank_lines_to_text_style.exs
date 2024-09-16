defmodule RenewCollab.Repo.Migrations.AddBlankLinesToTextStyle do
  use Ecto.Migration

  def change do
    alter table(:element_text_style) do
      add :blank_lines,
          :boolean,
          null: false,
          default: false
    end
  end
end
