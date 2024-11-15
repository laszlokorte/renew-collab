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
    query =
      case relative do
        :parent ->
          from(l in Layer,
            left_join: t in assoc(l, :direct_parent_layer),
            where: l.document_id == ^document_id and l.id == ^layer_id
          )

        {:sibling, pos} ->
          from(
            l in Layer,
            left_join: p in assoc(l, :direct_parent_hood),
            left_join: s in assoc(p, :siblings),
            left_join: t in assoc(l, :layers_of_document),
            left_join: rp in assoc(t, :direct_parent_hood),
            where: t.id != l.id and l.document_id == ^document_id and l.id == ^layer_id,
            where: (is_nil(p.id) and is_nil(rp.id)) or s.descendant_id == t.id,
            where:
              (^(pos == :first) and l.z_index > t.z_index) or
                (^(pos == :last) and l.z_index < t.z_index) or
                (^(pos == :prev) and l.z_index > t.z_index) or
                (^(pos == :next) and l.z_index < t.z_index),
            order_by: [
              {^case pos do
                 :first -> :asc
                 :last -> :desc
                 :prev -> :desc
                 :next -> :asc
               end, t.z_index}
            ],
            limit: 1
          )

        {:child, pos} ->
          from(t in Layer,
            left_join: p in assoc(t, :direct_parent_layer),
            where: p.document_id == ^document_id and p.id == ^layer_id,
            order_by: [
              {^case pos do
                 :first -> :asc
                 :last -> :desc
               end, t.z_index}
            ],
            limit: 1
          )
      end

    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      if(id_only,
        do:
          from(t in query,
            select: t.id
          ),
        else:
          from(t in query,
            select: t
          )
      )
    )
  end
end
