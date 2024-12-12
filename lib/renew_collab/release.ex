defmodule RenewCollab.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :renew_collab

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed do
    load_app()

    Ecto.Migrator.with_repo(RenewCollab.Repo, &RenewCollab.Init.reset(&1))
  end

  def create_account(email, password) do
    load_app()

    Ecto.Migrator.with_repo(RenewCollabAuth.Repo, fn r ->
      %RenewCollabAuth.Entites.Account{}
      |> RenewCollabAuth.Entites.Account.changeset(%{
        "email" => email,
        "new_password" => password
      })
      |> r.insert()
    end)
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
