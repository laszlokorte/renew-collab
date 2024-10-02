defmodule RenewCollab.Commands.UpdateLayerBoxSize do
  import Ecto.Query, warn: false

  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Text
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Hyperlink

  defstruct [:document_id, :layer_id, :new_size]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        new_size: new_size
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      new_size: new_size
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        new_size: new_size
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :box,
      from(l in Layer, join: b in assoc(l, :box), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{box: box} ->
        Box.change_size(box, new_size)
      end
    )
    |> Ecto.Multi.update_all(
      :update_linked_textes,
      fn %{box: %{position_x: old_x, position_y: old_y}} ->
        dx = Map.get(new_size, "position_x", old_x) - old_x
        dy = Map.get(new_size, "position_y", old_y) - old_y

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
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{box: box} ->
        from(own_box in Box,
          join: own_layer in assoc(own_box, :layer),
          join: edge in assoc(own_layer, :attached_edges),
          join: bond in assoc(edge, :bonds),
          join: layer in assoc(bond, :layer),
          join: box in assoc(layer, :box),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: own_box.id == ^box.id,
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
