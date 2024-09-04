defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Hierarchy.LayerParenthood

  def list_documents do
    Repo.all(Document, order_by: [asc: :inserted_at])
  end

  def get_document!(id), do: Repo.get!(Document, id)

  def get_document_with_elements!(id),
    do:
      Repo.get!(Document, id)
      |> Repo.preload(
        layers:
          from(e in Layer,
            order_by: [asc: :z_index],
            preload: [
              box: [],
              text: [style: []],
              edge: [
                waypoints: ^from(w in Waypoint, order_by: [asc: :sort]),
                style: []
              ],
              style: [],
              sockets: []
            ]
          )
      )

  def create_document(attrs \\ %{}) do
    %Document{layers: []}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  def create_element(%Document{} = document, attrs \\ %{}) do
    {:ok, %{insert_layer: layer}} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :insert_layer,
        Layer.changeset(%Layer{document_id: document.id}, attrs)
      )
      |> Ecto.Multi.insert(
        :insert_parenthood,
        fn %{insert_layer: new_layer} ->
          LayerParenthood.changeset(%LayerParenthood{}, %{
            depth: 0,
            document_id: new_layer.document_id,
            ancestor_id: new_layer.id,
            descendant_id: new_layer.id
          })
        end
      )
      |> Repo.transaction()

    {:ok, layer}
  end

  def get_element!(document, id) do
    Repo.get_by(Layer, id: id, document: document)
    |> Repo.preload(
      box: [],
      text: [style: []],
      edge: [
        waypoints: from(w in Waypoint, order_by: [asc: :sort]),
        style: []
      ],
      style: [],
      sockets: []
    )
  end
end
