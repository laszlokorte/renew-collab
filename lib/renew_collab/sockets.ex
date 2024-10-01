defmodule RenewCollab.Sockets do
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Repo
  import Ecto.Query, warn: false

  def ids_by_name do
    from(p in SocketSchema, join: s in assoc(p, :sockets), select: {{p.name, s.name}, s.id})
    |> Repo.all()
    |> Map.new()
  end

  def schemas_by_name do
    from(p in SocketSchema, join: s in assoc(p, :sockets), select: {p.name, p.id})
    |> Repo.all()
    |> Map.new()
  end

  def all_socket_schemas do
    from(p in SocketSchema,
      left_join: s in assoc(p, :sockets),
      order_by: [asc: p.name],
      preload: [sockets: s]
    )
    |> Repo.all()
    |> Enum.map(&{&1.id, &1})
    |> Map.new()
  end
end
