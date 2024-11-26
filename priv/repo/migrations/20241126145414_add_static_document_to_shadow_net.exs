defmodule RenewCollab.Repo.Migrations.AddStaticDocumentToShadowNet do
  use Ecto.Migration

  def change do
    alter table(:shadow_net) do
      add :document_json, :binary, null: true, default: nil
    end
  end
end
