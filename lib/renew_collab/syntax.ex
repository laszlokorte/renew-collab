defmodule RenewCollab.Syntax do
  alias RenewCollab.Repo
  alias RenewCollab.Syntax.SyntaxType
  alias RenewCollab.Syntax.SyntaxDefault
  alias RenewCollab.Syntax.SyntaxEdgeAutoTarget
  alias RenewCollab.Syntax.SyntaxEdgeWhitelist
  import Ecto.Query, warn: false

  def find_all() do
    from(s in SyntaxType)
    |> Repo.all()
    |> Repo.preload([
      :edge_whitelists,
      :edge_auto_targets,
      :default
    ])
  end

  def find(id) do
    from(s in SyntaxType,
      where: s.id == ^id
    )
    |> Repo.one()
    |> Repo.preload([
      :edge_whitelists,
      {:edge_auto_targets,
       [
         :target_socket
       ]},
      :default
    ])
  end

  def create(params) do
    %SyntaxType{}
    |> SyntaxType.changeset(params)
    |> Repo.insert()
  end

  def delete(id) do
    from(s in SyntaxType,
      where: s.id == ^id
    )
    |> Repo.delete_all()
    |> case do
      {1, _} ->
        :ok
    end
  end

  def delete_whitelist(id) do
    from(s in SyntaxEdgeWhitelist,
      where: s.id == ^id
    )
    |> Repo.delete_all()
    |> case do
      {1, _} ->
        :ok
    end
  end

  def delete_autonode(id) do
    from(s in SyntaxEdgeAutoTarget,
      where: s.id == ^id
    )
    |> Repo.delete_all()
    |> case do
      {1, _} ->
        :ok
    end
  end

  def make_default(id) do
    Repo.transact(fn _ ->
      from(s in SyntaxDefault)
      |> Repo.delete_all()

      %SyntaxDefault{syntax_id: id}
      |> Repo.insert()
    end)
    |> case do
      {:ok, _} ->
        nil
    end
  end

  def add_whitelist(%{"syntax_id" => syntax_id} = params) do
    %SyntaxEdgeWhitelist{syntax_id: syntax_id}
    |> SyntaxEdgeWhitelist.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, s} ->
        {:ok, s}

      e ->
        e
    end
  end

  def add_autonode(%{"syntax_id" => syntax_id} = params) do
    %SyntaxEdgeAutoTarget{syntax_id: syntax_id}
    |> SyntaxEdgeAutoTarget.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, s} ->
        {:ok, s}

      e ->
        e
    end
  end
end
