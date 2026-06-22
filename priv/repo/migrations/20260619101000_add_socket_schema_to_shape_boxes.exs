defmodule RenewCollab.Repo.Migrations.AddSocketSchemaToShapeBoxes do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Interface
  alias RenewCollab.Hierarchy.Layer

  @fallback_rect_socket_schema_id "4FDF577B-DB81-462E-971E-FA842F0ABA1E"
  @fallback_ellipse_socket_schema_id "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC"
  @fallback_rhombus_socket_schema_id "9F3C1A52-7E64-4D2B-9C18-2A7B5E0C4D11"

  @ellipse_tags [
    "de.renew.gui.PlaceFigure",
    "de.renew.gui.VirtualPlaceFigure",
    "CH.ifa.draw.figures.EllipseFigure",
    "CH.ifa.draw.figures.PieFigure",
    "de.renew.fa.figures.FAStateFigure"
  ]

  @rect_tags [
    "de.renew.gui.TransitionFigure",
    "de.renew.gui.VirtualTransitionFigure",
    "CH.ifa.draw.figures.RectangleFigure",
    "CH.ifa.draw.figures.RoundRectangleFigure",
    "CH.ifa.draw.contrib.TriangleFigure",
    "CH.ifa.draw.figures.TargetFigure"
  ]

  @rhombus_tags [
    "CH.ifa.draw.contrib.DiamondFigure"
  ]

  def up do
    schema_ids = %{
      "simple-rect" => socket_schema_id("simple-rect", @fallback_rect_socket_schema_id),
      "simple-ellipse" => socket_schema_id("simple-ellipse", @fallback_ellipse_socket_schema_id),
      "simple-rhombus" => socket_schema_id("simple-rhombus", @fallback_rhombus_socket_schema_id)
    }

    missing_interfaces =
      repo().all(
        from(l in Layer,
          join: b in Box,
          on: b.layer_id == l.id,
          left_join: i in Interface,
          on: i.layer_id == l.id,
          where:
            is_nil(i.id) and
              l.semantic_tag in ^(@ellipse_tags ++ @rect_tags ++ @rhombus_tags),
          select: {l.id, l.semantic_tag}
        )
      )

    insert_missing_interfaces(missing_interfaces, schema_ids)
  end

  def down do
    :ok
  end

  defp socket_schema_id(name, fallback) do
    repo().one(from(s in SocketSchema, where: s.name == ^name, select: s.id)) || fallback
  end

  defp insert_missing_interfaces([], _schema_ids), do: :ok

  defp insert_missing_interfaces(missing_interfaces, schema_ids) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      missing_interfaces
      |> Enum.map(fn {layer_id, semantic_tag} ->
        %{
          id: Ecto.UUID.generate(),
          layer_id: layer_id,
          socket_schema_id: schema_ids[socket_schema_name(semantic_tag)],
          inserted_at: now,
          updated_at: now
        }
      end)
      |> Enum.reject(&is_nil(&1.socket_schema_id))

    repo().insert_all(Interface, rows, on_conflict: :nothing, conflict_target: [:layer_id])
  end

  defp socket_schema_name(semantic_tag) when semantic_tag in @ellipse_tags, do: "simple-ellipse"
  defp socket_schema_name(semantic_tag) when semantic_tag in @rhombus_tags, do: "simple-rhombus"
  defp socket_schema_name(_semantic_tag), do: "simple-rect"
end
