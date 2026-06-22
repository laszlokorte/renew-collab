defmodule RenewCollab.Repo.Migrations.AddSocketSchemaToPolygons do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Element.Edge
  alias RenewCollab.Element.Interface
  alias RenewCollab.Hierarchy.Layer

  @fallback_rect_socket_schema_id "4FDF577B-DB81-462E-971E-FA842F0ABA1E"

  def up do
    socket_schema_id =
      repo().one(from(s in SocketSchema, where: s.name == "simple-rect", select: s.id)) ||
        @fallback_rect_socket_schema_id

    layer_ids =
      repo().all(
        from(l in Layer,
          join: e in Edge,
          on: e.layer_id == l.id,
          left_join: i in Interface,
          on: i.layer_id == l.id,
          where: e.cyclic == true and is_nil(i.id),
          select: l.id
        )
      )

    insert_polygon_interfaces(layer_ids, socket_schema_id)
    mark_cyclic_edges_as_polygons()
  end

  def down do
    :ok
  end

  defp insert_polygon_interfaces([], _socket_schema_id), do: :ok

  defp insert_polygon_interfaces(layer_ids, socket_schema_id) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(layer_ids, fn layer_id ->
        %{
          id: Ecto.UUID.generate(),
          layer_id: layer_id,
          socket_schema_id: socket_schema_id,
          inserted_at: now,
          updated_at: now
        }
      end)

    repo().insert_all(Interface, rows, on_conflict: :nothing, conflict_target: [:layer_id])
  end

  defp mark_cyclic_edges_as_polygons do
    repo().update_all(
      from(l in Layer,
        join: e in Edge,
        on: e.layer_id == l.id,
        where:
          e.cyclic == true and
            (is_nil(l.semantic_tag) or l.semantic_tag == "CH.ifa.draw.figures.PolyLineFigure")
      ),
      set: [semantic_tag: "CH.ifa.draw.figures.PolygonFigure"]
    )
  end
end
