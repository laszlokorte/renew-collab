defmodule RenewCollab.Commands.UpdateLayerEdgePoints do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Element.Edge
  alias RenewCollab.Element.Text
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :new_position, :waypoints]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        new_position: new_position,
        waypoints: waypoints
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      new_position: new_position,
      waypoints: List.wrap(waypoints)
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        new_position: new_position,
        waypoints: waypoints
      }) do
    waypoint_positions = Map.new(waypoints, &{value(&1, :id), &1})

    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(e in Edge,
        where: e.layer_id == ^layer_id,
        preload: [:waypoints]
      )
    )
    |> Ecto.Multi.one(:edge_center, edge_center_query(layer_id))
    |> Ecto.Multi.update(:position, fn %{edge: edge} ->
      Edge.change_position(edge, new_position)
    end)
    |> Ecto.Multi.merge(fn %{edge: edge} ->
      edge.waypoints
      |> Enum.reduce(Ecto.Multi.new(), fn waypoint, multi ->
        case Map.get(waypoint_positions, waypoint.id) do
          nil ->
            multi

          position ->
            Ecto.Multi.update(
              multi,
              {:waypoint, waypoint.id},
              Waypoint.change_position(waypoint, %{
                position_x: value(position, :x),
                position_y: value(position, :y)
              })
            )
        end
      end)
    end)
    |> Ecto.Multi.all(:affected_bond_ids, fn %{edge: edge} ->
      from(bond in Bond,
        where: bond.element_edge_id == ^edge.id,
        group_by: bond.id,
        select: bond.id
      )
    end)
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
    |> Ecto.Multi.one(:edge_center_delta, fn %{edge_center: {old_x, old_y}} ->
      edge_center_delta_query(layer_id, old_x, old_y)
    end)
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
    |> Ecto.Multi.one(
      :result_edge,
      from(l in Layer, join: e in assoc(l, :edge), where: l.id == ^layer_id, select: e)
    )
  end

  defp edge_center_query(layer_id) do
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
  end

  defp edge_center_delta_query(layer_id, old_x, old_y) do
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

  defp value(map, key) when is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end
end
