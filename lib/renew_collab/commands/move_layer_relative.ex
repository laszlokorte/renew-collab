defmodule RenewCollab.Commands.MoveLayerRelative do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Text
  alias RenewCollab.Element.Edge
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_ids, :dx, :dy]

  def new(%{document_id: document_id, layer_ids: layer_ids, dx: dx, dy: dy}) do
    %__MODULE__{
      document_id: document_id,
      layer_ids: normalize_layer_ids(layer_ids),
      dx: dx,
      dy: dy
    }
  end

  defp normalize_layer_ids(layer_ids) do
    layer_ids
    |> List.wrap()
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_ids: layer_ids,
        dx: dx,
        dy: dy
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.all(
      :combined_layer_ids,
      fn %{} ->
        base =
          from l in Layer,
            where: l.document_id == ^document_id and l.id in ^layer_ids,
            select: %{layer_id: l.id}

        hyprlink_out =
          from c in "component",
            join: h in Hyperlink,
            on: h.target_layer_id == c.layer_id,
            select: %{layer_id: h.source_layer_id}

        children =
          from c in "component",
            join: l in LayerParenthood,
            on: l.ancestor_id == c.layer_id and l.depth > 0,
            select: %{layer_id: l.descendant_id}

        cte =
          base
          |> union(^hyprlink_out)
          |> union(^children)

        Layer
        |> recursive_ctes(true)
        |> with_cte("component", as: ^cte)
        |> join(:inner, [l], c in "component", on: c.layer_id == l.id)
        |> select([l], l.id)
      end
    )
    |> Ecto.Multi.update_all(
      :update_boxes,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(b in Box,
            where: b.layer_id in ^combined_layer_ids,
            update: [inc: [position_x: ^dx, position_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_textes,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(t in Text,
            where: t.layer_id in ^combined_layer_ids,
            update: [inc: [position_x: ^dx, position_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_size_hint,
      fn %{combined_layer_ids: combined_layer_ids} ->
        from(h in TextSizeHint,
          where:
            h.text_id in subquery(
              from(t in Text,
                where: t.layer_id in ^combined_layer_ids,
                select: t.id
              )
            ),
          update: [inc: [position_x: ^dx, position_y: ^dy]]
        )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_edge_sources,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(e in Edge,
            left_join: b in Bond,
            on: b.element_edge_id == e.id and b.kind == :source,
            where: e.layer_id in ^combined_layer_ids,
            where: is_nil(b.id),
            update: [inc: [source_x: ^dx, source_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_edge_targets,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(e in Edge,
            left_join: b in Bond,
            on: b.element_edge_id == e.id and b.kind == :target,
            where: e.layer_id in ^combined_layer_ids,
            where: is_nil(b.id),
            update: [inc: [target_x: ^dx, target_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_waypoints,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(w in Waypoint,
            where:
              w.edge_id in subquery(
                from(e in Edge, select: e.id, where: e.layer_id in ^combined_layer_ids)
              ),
            update: [inc: [position_x: ^dx, position_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.all(
      :affected_bond_ids,
      fn %{combined_layer_ids: combined_layer_ids} ->
        attached_edge_bonds =
          from(layer in Layer,
            join: bond in assoc(layer, :attached_bonds),
            where: layer.id in ^combined_layer_ids,
            select: bond.id
          )

        moved_edge_bonds =
          from(edge in Edge,
            join: bond in assoc(edge, :bonds),
            where: edge.layer_id in ^combined_layer_ids,
            select: bond.id
          )

        attached_edge_bonds
        |> union(^moved_edge_bonds)
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
