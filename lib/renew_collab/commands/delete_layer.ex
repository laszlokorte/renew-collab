defmodule RenewCollab.Commands.DeleteLayer do
  import Ecto.Query, warn: false

  defstruct [:document_id, :layer_id, :delete_children]
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        delete_children: delete_children
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      delete_children: delete_children
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        delete_children: delete_children
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.all(:child_layers, fn %{document_id: document_id} ->
      from(p in LayerParenthood,
        where:
          p.ancestor_id == ^layer_id and p.document_id == ^document_id and
            (p.depth == 0 or ^delete_children),
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
    |> Ecto.Multi.delete_all(
      :delete_edges,
      fn %{
           document_id: document_id,
           connected_edge_layers: edge_layers,
           hyperlinked_layers: hyperlinked_layers
         } ->
        from(l in Layer,
          where:
            (l.id in ^edge_layers or l.id in ^hyperlinked_layers) and
              l.document_id == ^document_id
        )
      end,
      []
    )
    |> Ecto.Multi.delete_all(
      :delete_layer,
      fn %{document_id: document_id, child_layers: child_layers} ->
        from(l in Layer, where: l.id in ^child_layers and l.document_id == ^document_id)
      end,
      []
    )
  end
end
