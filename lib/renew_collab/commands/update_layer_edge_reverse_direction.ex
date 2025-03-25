defmodule RenewCollab.Commands.UpdateLayerEdgeReverseDirection do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Element.Edge
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Waypoint

  defstruct [:document_id, :layer_id]

  def new(%{document_id: document_id, layer_id: layer_id}) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: e in assoc(l, :edge), where: l.id == ^layer_id, select: e)
    )
    |> Ecto.Multi.update_all(
      :update_source_target,
      fn %{edge: edge} ->
        from(e in Edge,
          where: e.id == ^edge.id,
          update: [
            set: [
              source_x: ^edge.target_x,
              source_y: ^edge.target_y,
              target_x: ^edge.source_x,
              target_y: ^edge.source_y
            ]
          ]
        )
      end,
      []
    )
    |> Ecto.Multi.one(
      :waypoint_count,
      fn %{edge: edge} ->
        from(w in Waypoint,
          where: w.edge_id == ^edge.id,
          select: count(w.id)
        )
      end
    )
    |> Ecto.Multi.all(
      :old_bonds,
      fn %{edge: edge} ->
        from(b in Bond, where: b.element_edge_id == ^edge.id)
      end
    )
    |> Ecto.Multi.delete_all(
      :delete_old_bonds,
      fn %{edge: edge} ->
        from(b in Bond, where: b.element_edge_id == ^edge.id)
      end
    )
    |> Ecto.Multi.insert_all(
      :recreate_bonds,
      Bond,
      fn %{edge: edge, old_bonds: bonds} ->
        bonds
        |> Enum.map(&Bond.flip/1)
        |> Enum.map(fn %{
                         id: id,
                         element_edge_id: element_edge_id,
                         socket_id: socket_id,
                         layer_id: layer_id,
                         kind: kind,
                         inserted_at: inserted_at,
                         updated_at: updated_at
                       } ->
          %{
            id: id,
            element_edge_id: element_edge_id,
            socket_id: socket_id,
            layer_id: layer_id,
            kind: kind,
            inserted_at: inserted_at,
            updated_at: updated_at
          }
        end)
      end
    )
    |> Ecto.Multi.update_all(
      :update_waypoints,
      fn %{edge: edge} ->
        from(w in Waypoint,
          where: w.edge_id == ^edge.id,
          update: [
            set: [
              sort: -w.sort - 1
            ]
          ]
        )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      :repair_waypoint_sort,
      fn %{edge: edge, waypoint_count: wc} ->
        from(w in Waypoint,
          where: w.edge_id == ^edge.id,
          update: [
            inc: [
              sort: ^wc
            ]
          ]
        )
      end,
      []
    )
  end
end
