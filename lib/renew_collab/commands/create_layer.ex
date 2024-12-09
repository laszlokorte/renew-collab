defmodule RenewCollab.Commands.CreateLayer do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Element.Edge

  defstruct [:document_id, :attrs, :base_layer_id]

  def new(%{
        document_id: document_id,
        attrs: attrs,
        base_layer_id: base_layer_id
      }) do
    %__MODULE__{
      document_id: document_id,
      attrs: attrs,
      base_layer_id: base_layer_id
    }
  end

  def new(%{
        document_id: document_id,
        attrs: attrs
      }) do
    %__MODULE__{
      document_id: document_id,
      attrs: attrs,
      base_layer_id: nil
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        attrs: attrs,
        base_layer_id: base_layer_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :top_layer,
      fn %{document_id: document_id} ->
        from(l in Layer,
          left_join: dp in assoc(l, :direct_parent_hood),
          where: l.document_id == ^document_id and is_nil(dp.id),
          select: max(l.z_index)
        )
      end
    )
    |> Ecto.Multi.insert(
      :layer,
      fn %{document_id: document_id, top_layer: top_layer} ->
        %Layer{document_id: document_id}
        |> Layer.changeset(%{
          z_index: (top_layer || -1) + 1,
          semantic_tag: nil,
          hidden: false
        })
        |> Layer.changeset(attrs)
      end
    )
    |> Ecto.Multi.insert(
      :parenthood,
      fn %{layer: layer, document_id: document_id} ->
        %LayerParenthood{}
        |> LayerParenthood.changeset(%{
          document_id: document_id,
          ancestor_id: layer.id,
          descendant_id: layer.id,
          depth: 0
        })
      end
    )
    |> Ecto.Multi.all(
      :affected_bond_ids,
      fn %{layer: layer} ->
        from(edge in Edge,
          join: bond in assoc(edge, :bonds),
          where: edge.layer_id == ^layer.id,
          select: bond.id
        )
      end
    )
    |> Ecto.Multi.merge(fn %{document_id: document_id, layer: layer} ->
      case base_layer_id do
        nil ->
          Ecto.Multi.new()

        target_layer_id ->
          RenewCollab.Commands.ReorderLayer.new(%{
            document_id: document_id,
            layer_id: layer.id,
            target_layer_id: target_layer_id,
            target: {:above, :outside}
          })
          |> RenewCollab.Commands.ReorderLayer.multi()
      end
    end)
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
