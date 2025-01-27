defmodule RenewCollab.Commands.UpdateLayerEdgeWaypointPosition do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Element.Text
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :waypoint_id, :new_position]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id,
        new_position: new_position
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      waypoint_id: waypoint_id,
      new_position: new_position
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        waypoint_id: waypoint_id,
        new_position: new_position
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
          {coalesce(avg(w.position_x), (e.source_x + e.target_x) / 2),
           coalesce(avg(w.position_y), (e.source_y + e.target_y) / 2)}
      )
    )
    |> Ecto.Multi.update(
      :size,
      fn %{waypoint: waypoint} ->
        Waypoint.change_position(waypoint, new_position)
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
            {coalesce(avg(w.position_x), (e.source_x + e.target_x) / 2) - ^old_x,
             coalesce(avg(w.position_y), (e.source_y + e.target_y) / 2) - ^old_y}
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
