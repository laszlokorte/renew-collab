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
end
