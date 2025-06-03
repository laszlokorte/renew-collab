defmodule RenewCollabProj.Projects do
  @moduledoc """
  The Renew context.
  """

  alias RenewCollabProj.Entites.Project
  alias RenewCollabProj.Repo

  import Ecto.Query, warn: false

  def create_project(params) do
    %Project{} |> Project.changeset(params) |> Repo.insert()
  end

  def list_all_projects() do
    Repo.all(from(p in Project, order_by: [asc: :inserted_at]))
  end

  def find_project(id) do
    Repo.one(from(p in Project, where: p.id == ^id, order_by: [asc: :inserted_at]))
  end

  def delete_project(id) do
    Repo.delete_all(from(p in Project, where: p.id == ^id))
  end
end
