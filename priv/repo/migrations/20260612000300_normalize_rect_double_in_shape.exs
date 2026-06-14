defmodule RenewCollab.Repo.Migrations.NormalizeRectDoubleInShape do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Element.Box
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Symbol.Shape

  @obsolete_shape_id "E873CF6F-3F89-4B81-ABBA-5E932184CEDB"

  def up do
    with rect_double_in_id when is_binary(rect_double_in_id) <-
           canonical_shape_id("rect-double-in") do
      repo().update_all(
        from(b in Box,
          join: l in Layer,
          on: b.layer_id == l.id,
          where: l.semantic_tag == "de.renew.gui.VirtualTransitionFigure"
        ),
        set: [symbol_shape_id: rect_double_in_id]
      )

      sync_virtual_transition_primitive(rect_double_in_id)
      delete_obsolete_shape()
    end
  end

  def down do
    :ok
  end

  defp canonical_shape_id(name) do
    obsolete_shape_id = @obsolete_shape_id

    repo().one(
      from(s in Shape,
        where: s.name == ^name and s.id != ^obsolete_shape_id,
        order_by: [asc: s.id],
        select: s.id,
        limit: 1
      )
    )
  end

  defp sync_virtual_transition_primitive(shape_id) do
    case repo().one(from(p in PredefinedPrimitive, where: p.name == "Virtual Transition")) do
      nil ->
        :ok

      primitive ->
        data = primitive.data || %{}
        content_key = if Map.has_key?(data, "content"), do: "content", else: :content
        content = Map.get(data, content_key, %{})
        shape_key = if Map.has_key?(content, "shape_id"), do: "shape_id", else: :shape_id
        data = Map.put(data, content_key, Map.put(content, shape_key, shape_id))

        repo().update_all(from(p in PredefinedPrimitive, where: p.id == ^primitive.id),
          set: [data: data]
        )
    end
  end

  defp delete_obsolete_shape do
    obsolete_shape_id = @obsolete_shape_id
    repo().delete_all(from(s in Shape, where: s.id == ^obsolete_shape_id))
  end
end
