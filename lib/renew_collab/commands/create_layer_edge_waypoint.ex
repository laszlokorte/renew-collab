defmodule RenewCollab.Commands.CreateLayerEdgeWaypoint do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Element.Text
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :prev_waypoint_id, :position]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        prev_waypoint_id: prev_waypoint_id,
        position: position
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id,
      position: position
    }
  end

  def new(params) do
    new(params |> Map.put(:position, nil))
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        prev_waypoint_id: prev_waypoint_id,
        position: position
      }) do
    set_position =
      case position do
        {x, y} ->
          %{
            position_x: x,
            position_y: y
          }

        nil ->
          %{}
      end

    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      if is_nil(prev_waypoint_id) do
        from(l in Layer,
          join: e in assoc(l, :edge),
          left_join: w2 in assoc(e, :waypoints),
          left_join: w3 in assoc(e, :waypoints),
          where: l.id == ^layer_id,
          order_by: [asc: w2.sort],
          group_by: [w2.id, e.id],
          limit: 1,
          select: {e, nil, w2, max(w3.sort)}
        )
      else
        from(l in Layer,
          join: e in assoc(l, :edge),
          left_join: w in assoc(e, :waypoints),
          on: w.id == ^prev_waypoint_id,
          left_join: w2 in assoc(e, :waypoints),
          on: w2.sort > w.sort,
          left_join: w3 in assoc(e, :waypoints),
          where: l.id == ^layer_id,
          order_by: [asc: w2.sort],
          group_by: [w2.id, e.id, w.id],
          limit: 1,
          select: {e, w, w2, max(w3.sort)}
        )
      end
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
    |> Ecto.Multi.update_all(
      :increment_future_waypoints,
      fn
        %{edge: {_, _, _, nil}} ->
          from(w in Waypoint,
            where: false,
            update: [inc: [sort: 0]]
          )

        %{edge: {edge, nil, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id,
            update: [inc: [sort: ^(1 + max_sort * 2)]]
          )

        %{edge: {edge, prev_waypoint, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id and w.sort > ^prev_waypoint.sort,
            update: [inc: [sort: ^(1 + max_sort * 2)]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :offset_waypoints,
      fn
        %{edge: {_, _, _, nil}} ->
          from(w in Waypoint,
            where: false,
            update: [inc: [sort: 0]]
          )

        %{edge: {edge, nil, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id,
            update: [inc: [sort: ^(-max_sort * 2)]]
          )

        %{edge: {edge, prev_waypoint, _, max_sort}} ->
          from(w in Waypoint,
            where: w.edge_id == ^edge.id and w.sort > ^prev_waypoint.sort,
            update: [inc: [sort: ^(-max_sort * 2)]]
          )
      end,
      []
    )
    |> Ecto.Multi.insert(
      :waypoint,
      fn
        %{edge: {edge, nil, nil, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: 0,
            position_x: (edge.source_x + edge.target_x) / 2,
            position_y: (edge.source_y + edge.target_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, prev_waypoint, nil, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: prev_waypoint.sort + 1,
            position_x: (prev_waypoint.position_x + edge.target_x) / 2,
            position_y: (prev_waypoint.position_y + edge.target_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, nil, next_waypoint, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: next_waypoint.sort,
            position_x: (next_waypoint.position_x + edge.source_x) / 2,
            position_y: (next_waypoint.position_y + edge.source_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)

        %{edge: {edge, prev_waypoint, next_waypoint, _max_sort}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: next_waypoint.sort,
            position_x: (next_waypoint.position_x + prev_waypoint.position_x) / 2,
            position_y: (next_waypoint.position_y + prev_waypoint.position_y) / 2,
            edge_id: edge.id
          })
          |> Waypoint.changeset(set_position)
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
