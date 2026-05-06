defmodule RenewCollab.Sockets do
  def ids_by_name do
    RenewCollab.Queries.SocketIdsByName.new()
    |> RenewCollab.Queries.SocketIdsByName.multi()
    |> RenewCollab.Repo.transact()
    |> then(fn {:ok, %{result: result}} -> result end)
  end

  def schemas_by_name do
    RenewCollab.Queries.SocketSchemasByName.new()
    |> RenewCollab.Queries.SocketSchemasByName.multi()
    |> RenewCollab.Repo.transact()
    |> then(fn {:ok, %{result: result}} -> result end)
  end

  def all_socket_by_id do
    RenewCollab.Queries.SocketsById.new()
    |> RenewCollab.Queries.SocketsById.multi()
    |> RenewCollab.Repo.transact()
    |> then(fn {:ok, %{result: result}} -> result end)
  end

  def find_socket_schema(id) do
    import Ecto.Query

    from(p in RenewCollab.Connection.SocketSchema,
      order_by: [asc: p.name],
      where: p.id == ^id
    )
    |> RenewCollab.Repo.one()
    |> RenewCollab.Repo.preload([:sockets])
  end

  def find_socket(id) do
    import Ecto.Query

    RenewCollab.Repo.one(
      from(s in RenewCollab.Connection.Socket,
        where: s.id == ^id
      )
    )
  end

  def change_schema(schema_id, params) do
    RenewCollab.Connection.SocketSchema
    |> RenewCollab.Repo.get!(schema_id)
    |> RenewCollab.Connection.SocketSchema.changeset(params)
    |> RenewCollab.Repo.update()
  end

  def delete_socket(socket_id) do
    RenewCollab.Connection.Socket
    |> RenewCollab.Repo.get!(socket_id)
    |> RenewCollab.Repo.delete()
  end

  def create_socket(params) do
    %RenewCollab.Connection.Socket{}
    |> RenewCollab.Connection.Socket.changeset(params)
    |> RenewCollab.Repo.insert()
  end

  def create_socket_schema(params) do
    %RenewCollab.Connection.SocketSchema{}
    |> RenewCollab.Connection.SocketSchema.changeset(params)
    |> RenewCollab.Repo.insert()
  end

  def delete_socket_schema(socket_schema_id) do
    RenewCollab.Connection.SocketSchema
    |> RenewCollab.Repo.get!(socket_schema_id)
    |> RenewCollab.Repo.delete()
  end
end
