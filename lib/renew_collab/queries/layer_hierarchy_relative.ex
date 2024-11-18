defmodule RenewCollab.Queries.LayerHierarchyRelative do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :relative, :id_only]

  def new(%{document_id: document_id, layer_id: layer_id, relative: relative, id_only: id_only}) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      relative: relative,
      id_only: id_only
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        relative: relative,
        id_only: id_only
      }) do
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
          |> then(&if(id_only, do: select(exclude(&1, :select), [l, s], s.id), else: &1))

        {:sibling, pos} ->
          from(
            l in Layer,
            left_join: p in assoc(l, :direct_parent_hood),
            left_join: s in assoc(p, :siblings),
            left_join: r in assoc(l, :layers_of_document),
            left_join: rp in assoc(r, :direct_parent_hood),
            where: r.id != l.id and l.document_id == ^document_id and l.id == ^layer_id,
            where: (is_nil(p.id) and is_nil(rp.id)) or s.descendant_id == r.id,
            where:
              (^(pos == :first) and l.z_index > r.z_index) or
                (^(pos == :last) and l.z_index < r.z_index) or
                (^(pos == :prev) and l.z_index > r.z_index) or
                (^(pos == :next) and l.z_index < r.z_index),
            order_by: [
              {^case pos do
                 :first -> :asc
                 :last -> :desc
                 :prev -> :desc
                 :next -> :asc
               end, r.z_index}
            ],
            limit: 1,
            select: r
          )
          |> then(
            &if(id_only, do: select(exclude(&1, :select), [l, p, s, r, rp], r.id), else: &1)
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
          |> then(&if(id_only, do: select(exclude(&1, :select), [l, p], l.id), else: &1))
      end
    )
  end

  def parse_relative("parent"), do: :parent
  def parse_relative("sibling_first"), do: {:sibling, :first}
  def parse_relative("sibling_last"), do: {:sibling, :last}
  def parse_relative("sibling_prev"), do: {:sibling, :prev}
  def parse_relative("sibling_next"), do: {:sibling, :next}
  def parse_relative("child_first"), do: {:child, :first}
  def parse_relative("child_last"), do: {:child, :last}
end
