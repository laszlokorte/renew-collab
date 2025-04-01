defmodule RenewCollab.Repo.Migrations.AddPredefinedGroups do
  use Ecto.Migration

  def change do
    create table(:predefined_primitive_group, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string, null: false
    end

    create unique_index(:predefined_primitive_group, [:name])

    alter table(:predefined_primitive) do
      add :predefined_primitive_group_id,
          references(:predefined_primitive_group, on_delete: :delete_all, type: :binary_id)
    end
  end
end
