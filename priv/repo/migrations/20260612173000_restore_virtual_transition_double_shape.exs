defmodule RenewCollab.Repo.Migrations.RestoreVirtualTransitionDoubleShape do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Element.Box
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Symbol.Shape

  def up do
    RenewCollab.Symbols.ensure_custom_shapes_multi()
    |> repo().transaction()

    with rect_double_in_id when is_binary(rect_double_in_id) <- shape_id("rect-double-in") do
      repo().update_all(
        from(b in Box,
          join: l in Layer,
          on: b.layer_id == l.id,
          where: l.semantic_tag == "de.renew.gui.VirtualTransitionFigure"
        ),
        set: [symbol_shape_id: rect_double_in_id]
      )

      sync_virtual_transition_primitive(rect_double_in_id)
    end
  end

  def down do
    :ok
  end

  defp sync_virtual_transition_primitive(shape_id) do
    case repo().one(from(p in PredefinedPrimitive, where: p.name == "Virtual Transition")) do
      nil ->
        :ok

      primitive ->
        data =
          primitive.data
          |> ensure_map()
          |> put_content_value(:semantic_tag, "de.renew.gui.VirtualTransitionFigure")
          |> put_content_value(:shape_id, shape_id)
          |> put_content_value(:socket_schema_id, socket_schema_id("simple-rect"))
          |> put_content_value(:width, 24)
          |> put_content_value(:height, 16)

        repo().update_all(from(p in PredefinedPrimitive, where: p.id == ^primitive.id),
          set: [
            data: data,
            icon:
              ~s(<rect fill="none" x="1" y="5" width="30" height="22" stroke="#047138" stroke-width="2" /><rect fill="#24d188" x="7" y="9" width="18" height="14" stroke="#047138" stroke-width="2" />)
          ]
        )
    end
  end

  defp put_content_value(data, key, value) do
    content_key = existing_key(data, :content)
    content = Map.get(data, content_key, %{}) |> ensure_map()
    content = Map.put(content, existing_key(content, key), value)
    Map.put(data, content_key, content)
  end

  defp existing_key(map, atom_key) do
    string_key = Atom.to_string(atom_key)

    cond do
      Map.has_key?(map, atom_key) -> atom_key
      Map.has_key?(map, string_key) -> string_key
      true -> atom_key
    end
  end

  defp ensure_map(nil), do: %{}
  defp ensure_map(map) when is_map(map), do: map

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
