defmodule RenewCollab.Commands.CreateEdgeBond do
  import Ecto.Query, warn: false
  alias RenewCollab.Connection.Bond

  defstruct [:document_id, :edge_id, :kind, :layer_id, :socket_id]

  def new(%{
        document_id: document_id,
        edge_id: edge_id,
        kind: kind,
        layer_id: layer_id,
        socket_id: socket_id
      }) do
    %__MODULE__{
      document_id: document_id,
      edge_id: edge_id,
      kind: kind,
      layer_id: layer_id,
      socket_id: socket_id
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        edge_id: edge_id,
        kind: kind,
        layer_id: layer_id,
        socket_id: socket_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.insert(
      :new_bond,
      %Bond{}
      |> Bond.changeset(%{
        element_edge_id: edge_id,
        kind: kind,
        layer_id: layer_id,
        socket_id: socket_id
      })
    )
    |> Ecto.Multi.all(
      :affected_bonds,
      fn %{new_bond: bond} ->
        from(bond in Bond,
          join: l in assoc(bond, :layer),
          join: box in assoc(l, :box),
          join: edge in assoc(bond, :element_edge),
          join: socket in assoc(bond, :socket),
          join: socket_schema in assoc(socket, :socket_schema),
          where: bond.element_edge_id == ^bond.element_edge_id,
          group_by: bond.id,
          select: %{
            bond: bond,
            box: box,
            edge: edge,
            socket: socket,
            socket_schema: socket_schema
          }
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
