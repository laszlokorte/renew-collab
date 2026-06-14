defmodule RenewCollab.Repo.Migrations.UseDoubleShapeForVirtualTransitions do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Element.Box
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Symbol.Shape

  def up do
    with rect_shape_id when is_binary(rect_shape_id) <- shape_id("rect-double-in") || shape_id("rect") do
      repo().update_all(
        from(b in Box,
          join: l in Layer,
          on: b.layer_id == l.id,
          where: l.semantic_tag == "de.renew.gui.VirtualTransitionFigure"
        ),
        set: [symbol_shape_id: rect_shape_id]
      )

      sync_virtual_transition_primitive(rect_shape_id)
    end
  end

  def down do
    :ok
  end

  defp sync_virtual_transition_primitive(rect_shape_id) do
    repo().update_all(
      from(p in PredefinedPrimitive, where: p.name == "Virtual Transition"),
      set: [
        data: %{
          content: %{
            semantic_tag: "de.renew.gui.VirtualTransitionFigure",
            shape_id: rect_shape_id,
            socket_schema_id: socket_schema_id("transition"),
            width: 24,
            height: 16
          },
          mimeType: "application/json+renewex-layer",
          alignX: 0.5,
          alignY: 0.5
        },
        icon:
          ~s(<rect fill="#24d188" x="1" y="5" width="30" height="22" stroke="#047138" stroke-width="2" />\n<rect fill="none" x="5" y="9" width="22" height="14" stroke="#047138" stroke-width="2" />)
      ]
    )
  end

  defp shape_id(name) do
    repo().one(from(s in Shape, where: s.name == ^name, select: s.id)) ||
      Map.get(RenewCollab.Symbols.custom_shape_ids_by_name(), name)
  end

  defp socket_schema_id(name) do
    repo().one(
      from(s in RenewCollab.Connection.SocketSchema,
        where: s.name == ^name,
        select: s.id
      )
    )
  end
end
