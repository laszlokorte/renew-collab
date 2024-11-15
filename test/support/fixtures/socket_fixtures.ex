defmodule RenewCollab.SocketFixtures do
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Repo

  def interface_fixture() do
    RenewexRouting.Predefined.all()
    |> Enum.reduce(
      Ecto.Multi.new(),
      fn socket_schema, m ->
        m
        |> Ecto.Multi.insert(
          {:insert_socke_schema, Map.get(socket_schema, :name)},
          %SocketSchema{id: Map.get(socket_schema, :id)}
          |> SocketSchema.changeset(socket_schema)
        )
      end
    )
    |> Repo.transaction()
  end
end
