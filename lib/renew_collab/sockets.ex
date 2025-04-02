defmodule RenewCollab.Sockets do
  def ids_by_name do
    RenewCollab.Queries.SocketIdsByName.new()
    |> RenewCollab.Fetcher.fetch(:infinity)
  end

  def schemas_by_name do
    RenewCollab.Queries.SocketSchemasByName.new()
    |> RenewCollab.Fetcher.fetch(:infinity)
  end

  def all_socket_schemas do
    RenewCollab.Queries.SocketSchemasList.new()
    |> RenewCollab.Fetcher.fetch(:infinity)
  end

  def all_socket_by_id do
    RenewCollab.Queries.SocketsById.new()
    |> RenewCollab.Fetcher.fetch(:infinity)
  end

  def find_socket_schema(id) do
    import Ecto.Query

    RenewCollab.Repo.one(
      from(p in RenewCollab.Connection.SocketSchema,
        left_join: s in assoc(p, :sockets),
        order_by: [asc: p.name],
        where: p.id == ^id,
        preload: [sockets: s]
      )
    )
  end

  def change_schema(schema_id, params) do
    RenewCollab.Connection.SocketSchema
    |> RenewCollab.Repo.get!(schema_id)
    |> RenewCollab.Connection.SocketSchema.changeset(params)
    |> RenewCollab.Repo.update()
    |> case do
      {:ok, _} ->
        RenewCollab.SimpleCache.delete_tags([:sockets])
    end
  end

  def delete_socket(socket_id) do
    RenewCollab.Connection.Socket
    |> RenewCollab.Repo.get!(socket_id)
    |> RenewCollab.Repo.delete()
    |> case do
      {:ok, _} ->
        RenewCollab.SimpleCache.delete_tags([:sockets])
    end
  end

  def create_socket(params) do
    %RenewCollab.Connection.Socket{}
    |> RenewCollab.Connection.Socket.changeset(params)
    |> RenewCollab.Repo.insert()
    |> case do
      {:ok, _} ->
        RenewCollab.SimpleCache.delete_tags([:sockets])
    end
  end

  def create_socket_schema(params) do
    %RenewCollab.Connection.SocketSchema{}
    |> RenewCollab.Connection.SocketSchema.changeset(params)
    |> RenewCollab.Repo.insert()
    |> case do
      {:ok, _} ->
        RenewCollab.SimpleCache.delete_tags([:sockets])
    end
  end

  def delete_socket_schema(socket_schema_id) do
    RenewCollab.Connection.SocketSchema
    |> RenewCollab.Repo.get!(socket_schema_id)
    |> RenewCollab.Repo.delete()
    |> case do
      {:ok, _} ->
        RenewCollab.SimpleCache.delete_tags([:sockets])
    end
  end
end
