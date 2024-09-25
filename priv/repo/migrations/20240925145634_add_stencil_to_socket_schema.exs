defmodule RenewCollab.Repo.Migrations.AddStencilToSocketSchema do
  use Ecto.Migration

  def change do
    alter table(:socket_schema) do
      add :stencil, :string
    end
  end
end
