defmodule RenewCollab.Queries.LayerHierarchyRelative do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :relative]

  def new(%{document_id: document_id, layer_id: layer_id, relative: relative}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, relative: relative}
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, relative: relative}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      case relative do
        :parent ->
          from(l in Layer,
            left_join: s in assoc(l, :direct_parent_layer),
            where: l.document_id == ^document_id and l.id == ^layer_id,
            select: s
          )

        {:sibling, pos} ->
          from(l in Layer,
            left_join: s in assoc(l, :direct_sibling_layers),
            on: s.id != l.id,
            where: l.document_id == ^document_id and l.id == ^layer_id,
            where:
              (^(pos == :first) and l.z_index > s.z_index) or
                (^(pos == :last) and l.z_index < s.z_index) or
                (^(pos == :prev) and l.z_index > s.z_index) or
                (^(pos == :next) and l.z_index < s.z_index),
            order_by: [
              {^case pos do
                 :first -> :asc
                 :last -> :desc
                 :prev -> :desc
                 :next -> :asc
               end, s.z_index}
            ],
            limit: 1,
            select: s
          )

        {:child, pos} ->
          from(l in Layer,
            left_join: p in assoc(l, :direct_parent_layer),
            where: p.document_id == ^document_id and p.id == ^layer_id,
            order_by: [
              {^case pos do
                 :first -> :asc
                 :last -> :desc
               end, l.z_index}
            ],
            limit: 1,
            select: l
          )
      end
    )
  end
end
