defmodule RenewCollab.Commands.DeleteLayerEdgeWaypoint do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Element.Text
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :waypoint_id]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :waypoint,
      from(l in Layer,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        where: l.id == ^layer_id and w.id == ^waypoint_id,
        select: w
      )
    )
    |> Ecto.Multi.one(
      :edge_center,
      from(l in Layer,
        join: e in assoc(l, :edge),
        left_join: w in assoc(e, :waypoints),
        where: l.id == ^layer_id,
        select:
          {fragment(
             "(? + ? + coalesce(sum(?), 0.0)) / (count(?) + 2)",
             e.source_x,
             e.target_x,
             w.position_x,
             w.id
           ),
           fragment(
             "(? + ? + coalesce(sum(?), 0.0)) / (count(?) + 2)",
             e.source_y,
             e.target_y,
             w.position_y,
             w.id
           )},
        group_by: [e.source_x, e.source_y, e.target_x, e.target_y]
      )
    )
    |> Ecto.Multi.delete(
      :deletion,
      fn %{waypoint: waypoint} ->
        waypoint
      end
    )
    |> Ecto.Multi.all(
      :affected_bond_ids,
      fn %{waypoint: waypoint} ->
        from(bond in Bond,
          where: bond.element_edge_id == ^waypoint.edge_id,
          select: bond.id
        )
      end
    )
    |> Ecto.Multi.one(
      :edge_center_delta,
      fn %{edge_center: {old_x, old_y}} ->
        from(l in Layer,
          join: e in assoc(l, :edge),
          left_join: w in assoc(e, :waypoints),
          where: l.id == ^layer_id,
          select:
            {fragment(
               "(? + ? + coalesce(sum(?), 0.0)) / (count(?) + 2)",
               e.source_x,
               e.target_x,
               w.position_x,
               w.id
             ) - ^old_x,
             fragment(
               "(? + ? + coalesce(sum(?), 0.0)) / (count(?) + 2)",
               e.source_y,
               e.target_y,
               w.position_y,
               w.id
             ) - ^old_y},
          group_by: [e.source_x, e.source_y, e.target_x, e.target_y]
        )
      end
    )
    |> Ecto.Multi.update_all(
      :update_linked_textes,
      fn %{edge_center_delta: {dx, dy}} ->
        from(t in Text,
          update: [inc: [position_x: ^dx, position_y: ^dy]],
          where:
            t.layer_id in subquery(
              from(h in Hyperlink,
                select: h.source_layer_id,
                where: h.target_layer_id == ^layer_id
              )
            )
        )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_linked_textes_size_hint,
      fn %{edge_center_delta: {dx, dy}} ->
        from(h in TextSizeHint,
          update: [inc: [position_x: ^dx, position_y: ^dy]],
          where:
            h.text_id in subquery(
              from(h in Hyperlink,
                join: l in assoc(h, :source_layer),
                join: t in assoc(l, :text),
                select: t.id,
                where: h.target_layer_id == ^layer_id
              )
            )
        )
      end,
      []
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
