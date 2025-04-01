defmodule RenewCollab.Init do
  alias RenewCollab.Symbol.Shape
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Versioning
  alias RenewCollab.Syntax.SyntaxType
  alias RenewCollab.Primitives.PredefinedPrimitiveGroup
  import Ecto.Query, warn: false

  def reset(repo \\ RenewCollab.Repo) do
    try do
      Ecto.Multi.new()
      # |> Ecto.Multi.delete_all(:delete_documents, RenewCollab.Document.Document)
      # |> Ecto.Multi.delete_all(:delete_shapes, RenewCollab.Symbol.Shape)
      # |> Ecto.Multi.delete_all(:delete_socketschemas, RenewCollab.Connection.SocketSchema)
      |> then(
        &(RenewexIconset.Predefined.all()
          |> Enum.reduce(&1, fn shape, m ->
            m
            |> Ecto.Multi.insert_or_update(
              {:insert_shape, Map.get(shape, :name)},
              %Shape{id: Map.get(shape, :id)} |> Shape.changeset(shape),
              on_conflict: :nothing
            )
          end))
      )
      |> then(
        &(RenewexRouting.Predefined.all()
          |> Enum.reduce(&1, fn socket_schema, m ->
            m
            |> Ecto.Multi.insert_or_update(
              {:insert_socket_schema, Map.get(socket_schema, :name)},
              %SocketSchema{id: Map.get(socket_schema, :id)}
              |> SocketSchema.changeset(socket_schema),
              on_conflict: :nothing
            )
          end))
      )
      |> repo.transaction()
    rescue
      e -> dbg(e)
    end

    try do
      Ecto.Multi.new()
      |> Ecto.Multi.delete_all(:delete_syntax, SyntaxType)
      |> Ecto.Multi.delete_all(:delete_primitives, PredefinedPrimitiveGroup)
      |> then(
        &(RenewCollab.Syntax.Predefined.all()
          |> Enum.reduce(&1, fn syntax_type, m ->
            m
            |> Ecto.Multi.insert_or_update(
              {:insert_syntax_type, Map.get(syntax_type, :name)},
              %SyntaxType{id: Map.get(syntax_type, :id)}
              |> SyntaxType.changeset(syntax_type),
              on_conflict: :nothing
            )
          end))
      )
      |> then(
        &(RenewCollab.Primitives.Predefined.all()
          |> Enum.reduce(&1, fn primitive, m ->
            m
            |> Ecto.Multi.insert_or_update(
              {:insert_primitive, Map.get(primitive, :name)},
              %PredefinedPrimitiveGroup{id: Map.get(primitive, :id)}
              |> PredefinedPrimitiveGroup.changeset(primitive),
              on_conflict: :nothing
            )
          end))
      )
      |> repo.transaction()
    rescue
      e -> dbg(e)
    end

    for transient_doc = %{content: %{id: pre_id}} <- RenewCollab.Blueprints.all() do
      try do
        RenewCollab.Commands.CreateDocument.new(%{doc: transient_doc})
        |> RenewCollab.Commands.CreateDocument.multi(pre_id)
        |> Ecto.Multi.merge(fn %{insert_document: %{id: doc_id}} ->
          Versioning.snapshot_multi(doc_id)
        end)
        |> repo.transaction()
      rescue
        _e -> nil
      end
    end

    RenewCollab.SimpleCache.clear()
  end
end
