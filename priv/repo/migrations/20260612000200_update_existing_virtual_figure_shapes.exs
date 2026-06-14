defmodule RenewCollab.Repo.Migrations.UpdateExistingVirtualFigureShapes do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Element.Box
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Symbol.Shape

  def up do
    update_virtual_shape("de.renew.gui.VirtualPlaceFigure", "ellipse-double-in")
    update_virtual_shape("de.renew.gui.VirtualTransitionFigure", "rect-double-in")
  end

  def down do
    :ok
  end

  defp update_virtual_shape(semantic_tag, shape_name) do
    case shape_id(shape_name) do
      nil ->
        :ok

      shape_id ->
        repo().update_all(
          from(b in Box,
            join: l in Layer,
            on: b.layer_id == l.id,
            where: l.semantic_tag == ^semantic_tag
          ),
          set: [symbol_shape_id: shape_id]
        )
    end
  end

  defp shape_id(name) do
    repo().one(from(s in Shape, where: s.name == ^name, select: s.id)) ||
      Map.get(RenewCollab.Symbols.custom_shape_ids_by_name(), name)
  end
end
