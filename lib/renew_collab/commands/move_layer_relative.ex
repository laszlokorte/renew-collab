defmodule RenewCollab.Commands.MoveLayerRelative do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Text
  alias RenewCollab.Element.Edge
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :dx, :dy]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        dx: dx,
        dy: dy
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      dx: dx,
      dy: dy
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        dx: dx,
        dy: dy
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.all(:child_layers, fn %{document_id: document_id} ->
      from(p in LayerParenthood,
        where: p.ancestor_id == ^layer_id and p.document_id == ^document_id,
        select: p.descendant_id
      )
    end)
    |> Ecto.Multi.all(:connected_edge_layers, fn
      %{child_layers: child_layers} ->
        from(b in Bond,
          join: e in assoc(b, :element_edge),
          where: b.layer_id in ^child_layers,
          select: e.layer_id
        )
    end)
    |> Ecto.Multi.all(:hyperlinked_layers, fn
      %{child_layers: child_layers, connected_edge_layers: edge_layers} ->
        from(h in Hyperlink,
          where: h.target_layer_id in ^child_layers or h.target_layer_id in ^edge_layers,
          select: h.source_layer_id
        )
    end)
    |> Ecto.Multi.run(
      :combined_layer_ids,
      fn _,
         %{
           child_layers: child_layers,
           connected_edge_layers: connected_edge_layers,
           hyperlinked_layers: hyperlinked_layers
         } ->
        {:ok, Enum.concat([child_layers, connected_edge_layers, hyperlinked_layers])}
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
      :delete_size_hint,
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
      :update_edges,
      fn
        %{combined_layer_ids: combined_layer_ids} ->
          from(e in Edge,
            where: e.layer_id in ^combined_layer_ids,
            update: [inc: [source_x: ^dx, source_y: ^dy, target_x: ^dx, target_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :update_waypoints,
      fn
        %{child_layers: child_layers} ->
          from(w in Waypoint,
            where:
              w.edge_id in subquery(
                from(e in Edge, select: e.id, where: e.layer_id in ^child_layers)
              ),
            update: [inc: [position_x: ^dx, position_y: ^dy]]
          )
      end,
      []
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{combined_layer_ids: combined_layer_ids} ->
        from(own_box in Box,
          join: own_layer in assoc(own_box, :layer),
          join: edge in assoc(own_layer, :attached_edges),
          join: bond in assoc(edge, :bonds),
          join: layer in assoc(bond, :layer),
          join: box in assoc(layer, :box),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: own_layer.id in ^combined_layer_ids or edge.layer_id in ^combined_layer_ids,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            socket: socket,
            edge: edge,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
