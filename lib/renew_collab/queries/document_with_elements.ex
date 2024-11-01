defmodule RenewCollab.Queries.DocumentWithElements do
  import Ecto.Query, warn: false

  alias RenewCollab.Document.Document

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{
      document_id: document_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{document_id: document_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(d in Document,
        where: d.id == ^document_id,
        left_join: l in assoc(d, :layers),
        left_join: dp in assoc(l, :direct_parent),
        left_join: b in assoc(l, :box),
        left_join: ss in assoc(b, :symbol_shape),
        left_join: t in assoc(l, :text),
        left_join: e in assoc(l, :edge),
        left_join: sb in assoc(e, :source_bond),
        left_join: tb in assoc(e, :target_bond),
        left_join: w in assoc(e, :waypoints),
        left_join: ls in assoc(l, :style),
        left_join: ts in assoc(t, :style),
        left_join: es in assoc(e, :style),
        left_join: sh in assoc(t, :size_hint),
        left_join: i in assoc(l, :interface),
        left_join: ol in assoc(l, :outgoing_link),
        left_join: il in assoc(l, :incoming_links),
        left_join: cs in assoc(d, :current_snaptshot),
        left_join: ps in assoc(cs, :predecessor),
        left_join: ns in assoc(cs, :successors),
        order_by: [asc: l.z_index, asc: w.sort],
        preload: [
          current_snaptshot: {cs, [predecessor: ps, successors: ns]},
          layers:
            {l,
             [
               direct_parent: dp,
               box: {b, [symbol_shape: ss]},
               text: {t, [style: ts, size_hint: sh]},
               edge: {e, [style: es, waypoints: w, source_bond: sb, target_bond: tb]},
               style: ls,
               interface: i,
               outgoing_link: ol,
               incoming_links: il
             ]}
        ]
      )
    )
  end
end
