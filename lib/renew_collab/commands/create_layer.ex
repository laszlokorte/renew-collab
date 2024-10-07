defmodule RenewCollab.Commands.CreateLayer do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Element.Edge

  defstruct [:document_id, :attrs]

  def new(%{
        document_id: document_id,
        attrs: attrs
      }) do
    %__MODULE__{
      document_id: document_id,
      attrs: attrs
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        attrs: attrs
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.insert(
      :layer,
      fn %{document_id: document_id} ->
        %Layer{document_id: document_id}
        |> Layer.changeset(%{
          z_index: 0,
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
    |> Ecto.Multi.append(RenewCollab.Bonding.reposition_multi())
  end
end
