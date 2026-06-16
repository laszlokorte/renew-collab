defmodule RenewCollab.Commands.CreateEdgeBond do
  import Ecto.Query, warn: false
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Element.Edge
  alias RenewCollab.Hierarchy.Layer

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

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        edge_id: edge_id,
        kind: kind,
        layer_id: layer_id,
        socket_id: socket_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :edge,
      from(edge in Edge,
        join: layer in Layer,
        on: layer.id == edge.layer_id,
        where:
          layer.document_id == ^document_id and (edge.id == ^edge_id or layer.id == ^edge_id),
        select: edge
      )
    )
    |> Ecto.Multi.delete_all(
      :old_endpoint_bond,
      fn %{edge: edge} ->
        from(bond in Bond,
          where: bond.element_edge_id == ^edge.id and bond.kind == ^kind
        )
      end
    )
    |> Ecto.Multi.insert(
      :new_bond,
      fn %{edge: edge} ->
        %Bond{}
        |> Bond.changeset(%{
          element_edge_id: edge.id,
          kind: kind,
          layer_id: layer_id,
          socket_id: socket_id
        })
      end
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
