defmodule RenewCollab.Repo.Migrations.AddPredefinedPrimitive do
  use Ecto.Migration

  def change do
    create table(:predefined_primitive, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string, null: false
      add :content, :map, null: false
    end
  end
end
