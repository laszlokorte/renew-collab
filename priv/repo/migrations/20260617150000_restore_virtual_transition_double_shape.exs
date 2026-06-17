defmodule RenewCollab.Repo.Migrations.RestoreVirtualTransitionDoubleShapeAgain do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Element.Box
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Symbol.Shape

  @virtual_transition "de.renew.gui.VirtualTransitionFigure"
  @virtual_transition_shape "rect-double-in"

  def up do
    ensure_shape(@virtual_transition_shape)

    with rect_double_in_id when is_binary(rect_double_in_id) <-
           shape_id(@virtual_transition_shape) do
      update_existing_virtual_transitions(rect_double_in_id)
      sync_virtual_transition_primitive(rect_double_in_id)
    end
  end

  def down do
    :ok
  end

  defp update_existing_virtual_transitions(shape_id) do
    repo().update_all(
      from(b in Box,
        join: l in Layer,
        on: b.layer_id == l.id,
        where: l.semantic_tag == @virtual_transition
      ),
      set: [symbol_shape_id: shape_id]
    )
  end

  defp sync_virtual_transition_primitive(shape_id) do
    primitive_names = ["Virtual Transition Tool", "Virtual Transition"]

    repo().update_all(
      from(p in PredefinedPrimitive, where: p.name in ^primitive_names),
      set: [
        data: %{
          content: %{
            semantic_tag: @virtual_transition,
            shape_id: shape_id,
            socket_schema_id: socket_schema_id("simple-rect"),
            width: 24,
            height: 16
          },
          mimeType: "application/json+renewex-layer",
          alignX: 0.5,
          alignY: 0.5
        }
      ]
    )
  end

  defp shape_id(name) do
    repo().one(from(s in Shape, where: s.name == ^name, select: s.id))
  end

  defp ensure_shape(name) do
    if is_nil(shape_id(name)) do
      RenewCollab.Symbols.predefined_shapes()
      |> Enum.find(&(Map.get(&1, :name) == name))
      |> case do
        nil ->
          :ok

        shape ->
          %Shape{id: Map.get(shape, :id)}
          |> Shape.changeset(shape)
          |> repo().insert()
      end
    end
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
