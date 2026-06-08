defmodule RenewCollab.Queries.LayerAllReachable do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Element.Edge

  defstruct [:document_id, :layer_id, :ref_id, :downlink, :uplink]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        downlink: downlink,
        uplink: uplink
      })
      when is_boolean(downlink) and is_boolean(uplink) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      downlink: downlink,
      uplink: uplink
    }
  end

  def new(%{
        document_id: document_id,
        layer_id: layer_id
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      downlink: true,
      uplink: true
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        ref_id: ref_id,
        downlink: downlink,
        uplink: uplink
      }) do
    result_key = result_key(ref_id)

    base =
      from l in Layer,
        where: l.document_id == ^document_id and l.id == ^layer_id,
        select: %{layer_id: l.id}

    edge_step =
      from c in "component",
        join: b in Bond,
        on: b.layer_id == c.layer_id,
        join: e in Edge,
        on: e.id == b.element_edge_id,
        select: %{layer_id: e.layer_id}

    node_step =
      from c in "component",
        join: e in Edge,
        on: e.layer_id == c.layer_id,
        join: b in Bond,
        on: b.element_edge_id == e.id,
        select: %{layer_id: b.layer_id}

    hyprlink_in =
      from c in "component",
        join: h in Hyperlink,
        on: h.source_layer_id == c.layer_id,
        select: %{layer_id: h.target_layer_id}

    hyprlink_out =
      from c in "component",
        join: h in Hyperlink,
        on: h.target_layer_id == c.layer_id,
        select: %{layer_id: h.source_layer_id}

    children =
      from c in "component",
        join: l in LayerParenthood,
        on: l.ancestor_id == c.layer_id and l.depth > 0,
        select: %{layer_id: l.descendant_id}

    cte =
      base
      |> union(^node_step)
      |> union(^edge_step)
      |> then(&if(downlink, do: union(&1, ^hyprlink_in), else: &1))
      |> then(&if(uplink, do: union(&1, ^hyprlink_out), else: &1))
      |> union(^children)

    Ecto.Multi.new()
    |> Ecto.Multi.all(
      result_key,
      Layer
      |> recursive_ctes(true)
      |> with_cte("component", as: ^cte)
      |> join(:inner, [l], c in "component", on: c.layer_id == l.id)
      |> select([l], l.id)
    )
  end

  def result_key(nil), do: :result
  def result_key(ref_id), do: {ref_id, :result}
end
