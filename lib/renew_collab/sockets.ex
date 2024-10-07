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
end
