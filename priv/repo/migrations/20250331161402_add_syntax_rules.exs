defmodule RenewCollab.Repo.Migrations.AddSyntaxRules do
  use Ecto.Migration

  def change do
    create table(:syntax, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string, null: false
    end

    create table(:syntax_edge_whitelist, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :syntax_id, references(:syntax, on_delete: :delete_all, type: :binary_id), null: false

      add :source_semantic_tag, :string, null: false
      add :target_semantic_tag, :string, null: false
      add :edge_semantic_tag, :string, null: false
    end

    create unique_index(:syntax_edge_whitelist, [
             :syntax_id,
             :source_semantic_tag,
             :target_semantic_tag,
             :edge_semantic_tag
           ])

    create table(:syntax_edge_auto_target, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false

      add :syntax_id, references(:syntax, on_delete: :delete_all, type: :binary_id), null: false

      add :source_semantic_tag, :string, null: false

      add :source_socket_id, references(:socket, on_delete: :delete_all, type: :binary_id),
        null: false

      add :target_shape_id, references(:symbol_shape, on_delete: :delete_all, type: :binary_id),
        null: false

      add :target_semantic_tag, :string, null: false

      add :target_socket_id, references(:socket, on_delete: :delete_all, type: :binary_id),
        null: false

      add :edge_semantic_tag, :string, null: false

      add :edge_source_tip_id,
          references(:symbol_shape, on_delete: :nilify_all, type: :binary_id),
          null: true

      add :edge_target_tip_id,
          references(:symbol_shape, on_delete: :nilify_all, type: :binary_id),
          null: true
    end
  end
end
