defmodule RenewCollab.Commands.MakeSpaceBetween do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Text
  alias RenewCollab.Element.Edge
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :base, :direction, :inverse]

  def new(%{
        document_id: document_id,
        base: base,
        direction: direction,
        inverse: inverse
      }) do
    %__MODULE__{
      document_id: document_id,
      base: base,
      direction: direction,
      inverse: inverse
    }
  end

  def new(%{
        document_id: document_id,
        base: base,
        direction: direction
      }) do
    %__MODULE__{
      document_id: document_id,
      base: base,
      direction: direction,
      inverse: false
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        base: {bx, by},
        direction: {dx, dy},
        inverse: inverse
      }) do
    {mdx, mdy} = if(inverse, do: {-dx, -dy}, else: {dx, dy})

    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.update_all(
      :update_boxes,
      fn
        %{} ->
          from(b in Box,
            where:
              b.layer_id in subquery(
                from l in Layer, select: l.id, where: l.document_id == ^document_id
              ),
            where:
              (b.position_x + b.width / 2.0 - ^bx) * ^dx +
                (b.position_y + b.height / 2.0 - ^by) * ^dy >
                0.0,
            update: [inc: [position_x: ^mdx, position_y: ^mdy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_textes,
      fn
        %{} ->
          from(t in Text,
            where:
              t.layer_id in subquery(
                from l in Layer, select: l.id, where: l.document_id == ^document_id
              ),
            where: (t.position_x - ^bx) * ^dx + (t.position_y - ^by) * ^dy > 0.0,
            update: [inc: [position_x: ^mdx, position_y: ^mdy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_size_hint,
      fn %{} ->
        from(h in TextSizeHint,
          where:
            h.text_id in subquery(
              from(t in Text,
                where:
                  t.layer_id in subquery(
                    from l in Layer, select: l.id, where: l.document_id == ^document_id
                  ),
                where: (t.position_x - ^bx) * ^dx + (t.position_y - ^by) * ^dy > 0.0,
                select: t.id
              )
            ),
          update: [inc: [position_x: ^mdx, position_y: ^mdy]]
        )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_edges,
      fn
        %{} ->
          from(e in Edge,
            where:
              e.layer_id in subquery(
                from l in Layer, select: l.id, where: l.document_id == ^document_id
              ),
            where: (e.source_x - ^bx) * ^dx + (e.source_y - ^by) * ^dy > 0.0,
            where: (e.target_x - ^bx) * ^dx + (e.target_y - ^by) * ^dy > 0.0,
            update: [inc: [source_x: ^mdx, source_y: ^mdy, target_x: ^mdx, target_y: ^mdy]]
          )
      end,
      []
    )
    # |> Ecto.Multi.update_all(
    #   :update_edges_source,
    #   fn
    #     %{} ->
    #       from(e in Edge,
    #         where: e.layer_id in subquery(from l in Layer, select: l.id, where: l.document_id == ^document_id),
    #         where: ((e.source_x - ^bx) * ^dx + (e.source_y - ^by) * ^dy > 0.0),
    #         update: [inc: [source_x: ^dx, source_y: ^dy]]
    #       )
    #   end,
    #   []
    # )
    # |> Ecto.Multi.update_all(
    #   :update_edges_target,
    #   fn
    #     %{} ->
    #       from(e in Edge,
    #         where: e.layer_id in subquery(from l in Layer, select: l.id, where: l.document_id == ^document_id),
    #         where: ((e.target_x - ^bx) * ^dx + (e.target_y - ^by) * ^dy > 0.0),
    #         update: [inc: [target_x: ^dx, target_y: ^dy]]
    #       )
    #   end,
    #   []
    # )
    |> Ecto.Multi.update_all(
      :update_waypoints,
      fn
        %{} ->
          from(w in Waypoint,
            where:
              w.edge_id in subquery(
                from l in Layer,
                  join: e in assoc(l, :edge),
                  where: (e.source_x - ^bx) * ^dx + (e.source_y - ^by) * ^dy > 0.0,
                  where: (e.target_x - ^bx) * ^dx + (e.target_y - ^by) * ^dy > 0.0,
                  select: e.id,
                  where: l.document_id == ^document_id
              ),
            where: (w.position_x - ^bx) * ^dx + (w.position_y - ^by) * ^dy > 0.0,
            update: [inc: [position_x: ^mdx, position_y: ^mdy]]
          )
      end,
      []
    )
    |> Ecto.Multi.all(
      :affected_bond_ids,
      fn %{document_id: document_id} ->
        from(own_layer in Layer,
          join: edge in assoc(own_layer, :attached_edges),
          join: bond in assoc(edge, :bonds),
          where: own_layer.document_id == ^document_id,
          group_by: bond.id,
          select: bond.id
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
