defmodule RenewCollab.Init do
  alias RenewCollab.Document.Document
  alias RenewCollab.Symbol.Shape
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Repo
  import Ecto.Query, warn: false

  def reset do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.delete_all(:delete_documents, Document)
      |> Ecto.Multi.delete_all(:delete_shapes, Shape)
      |> Ecto.Multi.delete_all(:delete_socketschemas, SocketSchema)

    multi2 =
      RenewCollab.Symbol.PredefinedSymbols.all()
      |> Enum.reduce(multi, fn shape, m ->
        m
        |> Ecto.Multi.insert(
          "insert_#{Map.get(shape, :name)}",
          %Shape{id: Map.get(shape, :id)} |> Shape.changeset(shape)
        )
      end)

    multi3 =
      RenewCollab.Sockets.PredefinedSockets.all()
      |> Enum.reduce(multi2, fn socket_schema, m ->
        m
        |> Ecto.Multi.insert(
          "insert_#{Map.get(socket_schema, :name)}",
          %SocketSchema{id: Map.get(socket_schema, :id)}
          |> SocketSchema.changeset(socket_schema)
        )
      end)

    multi3
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        dbg("YES")
        raise "x"

      _ ->
        raise "x"
    end
  end
end
