defmodule RenewCollab.Init do
  alias RenewCollab.Document.Document
  alias RenewCollab.Symbol.Shape
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Versioning
  import Ecto.Query, warn: false

  def reset(repo \\ RenewCollab.Repo) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_documents, Document)
    |> Ecto.Multi.delete_all(:delete_shapes, Shape)
    |> Ecto.Multi.delete_all(:delete_socketschemas, SocketSchema)
    |> then(
      &(RenewexIconset.Predefined.all()
        |> Enum.reduce(&1, fn shape, m ->
          m
          |> Ecto.Multi.insert(
            {:insert_shape, Map.get(shape, :name)},
            %Shape{id: Map.get(shape, :id)} |> Shape.changeset(shape)
          )
        end))
    )
    |> then(
      &(RenewexRouting.Predefined.all()
        |> Enum.reduce(&1, fn socket_schema, m ->
          m
          |> Ecto.Multi.insert(
            {:insert_socke_schema, Map.get(socket_schema, :name)},
            %SocketSchema{id: Map.get(socket_schema, :id)}
            |> SocketSchema.changeset(socket_schema)
          )
        end))
    )
    |> then(
      &(RenewCollab.Blueprints.all()
        |> Enum.with_index()
        |> Enum.reduce(&1, fn {transient_doc, i}, m ->
          m
          |> Ecto.Multi.run(
            {:insert_blueprint, i},
            fn rep, %{} ->
              RenewCollab.Commands.CreateDocument.new(%{doc: transient_doc})
              |> RenewCollab.Commands.CreateDocument.multi()
              |> Ecto.Multi.append(Versioning.snapshot_multi())
              |> rep.transaction()
            end
          )
        end))
    )
    |> repo.transaction()
    |> case do
      {:ok, _} ->
        RenewCollab.SimpleCache.clear()
    end
  end
end
