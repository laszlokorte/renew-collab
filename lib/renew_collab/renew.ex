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

  def reset do
    Repo.delete_all(Document)
  end

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
              direct_parent: [],
              box: [
                symbol_shape: []
              ],
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

  def create_document(attrs \\ %{}, parenthoods \\ []) do
    with {:ok, transaction} <-
           Ecto.Multi.new()
           |> Ecto.Multi.insert(
             :insert_document,
             %Document{} |> Document.changeset(attrs)
           )
           |> Ecto.Multi.insert_all(
             :insert_parenthoods,
             LayerParenthood,
             fn %{insert_document: new_document} ->
               Enum.map(
                 parenthoods,
                 fn {ancestor_id, descendant_id, depth} ->
                   %{
                     depth: depth,
                     ancestor_id: ancestor_id,
                     descendant_id: descendant_id,
                     document_id: new_document.id
                   }
                 end
               )
             end,
             on_conflict: {:replace, [:depth, :ancestor_id, :descendant_id]}
           )
           |> Repo.transaction() do
      {:ok, Map.get(transaction, :insert_document)}
    else
      e -> dbg(e)
    end
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
      box: [
        symbol_shape: []
      ],
      text: [style: []],
      edge: [
        waypoints: from(w in Waypoint, order_by: [asc: :sort]),
        style: []
      ],
      style: [],
      sockets: []
    )
  end

  def toggle_visible(layer_id) do
    query =
      from(
        l in Layer,
        where: l.id == ^layer_id,
        update: [set: [hidden: not l.hidden]]
      )

    # Update the record
    Repo.update_all(query, [])
  end
end
