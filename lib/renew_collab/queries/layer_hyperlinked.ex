defmodule RenewCollab.Queries.LayerHyperlinked do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :deep, :ref_id]

  def new(
        %{
          document_id: document_id,
          layer_id: layer_id
        } = attrs
      ) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      deep: Map.get(attrs, :deep)
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        ref_id: ref_id,
        deep: false
      }) do
    result_key = result_key(ref_id)

    Ecto.Multi.new()
    |> Ecto.Multi.all(
      result_key,
      from(l in Layer,
        where: l.document_id == ^document_id,
        join: h in assoc(l, :outgoing_link),
        where: h.target_layer_id == ^layer_id,
        select: l.id
      )
    )
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        ref_id: ref_id,
        deep: true
      }) do
    result_key = result_key(ref_id)

    base_query =
      from(l in Layer,
        join: h in assoc(l, :outgoing_link),
        where:
          l.document_id == ^document_id and
            h.target_layer_id == ^layer_id,
        select: %{id: l.id}
      )

    recursive_query =
      from(l in Layer,
        join: h in assoc(l, :outgoing_link),
        join: ll in "linked_layers",
        on: h.target_layer_id == ll.id,
        where: l.document_id == ^document_id,
        select: %{id: l.id}
      )

    cte =
      base_query
      |> union(^recursive_query)

    Layer
    |> recursive_ctes(true)
    |> with_cte("linked_layers", as: ^cte)
    |> join(:inner, [l], ll in "linked_layers", on: ll.id == l.id)
    |> select([l], l.id)
    |> then(fn query ->
      Ecto.Multi.new()
      |> Ecto.Multi.all(result_key, query)
    end)
  end

  def result_key(nil), do: :result
  def result_key(ref_id), do: {ref_id, :result}
end
