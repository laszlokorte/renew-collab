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
      :affected_bond_ids,
      fn %{new_bond: new_bond} ->
        from(bond in Bond,
          where: bond.element_edge_id == ^new_bond.element_edge_id,
          select: bond.id
        )
      end
    )
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
