defmodule RenewCollab.Queries.DocumentWithElements do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Document.Document

  defstruct [:document_id, :root_layer_id]

  def new(%{document_id: document_id, root_layer_id: root_layer_id}) do
    %__MODULE__{
      document_id: document_id,
      root_layer_id: root_layer_id
    }
  end

  def new(%{document_id: document_id}) do
    %__MODULE__{
      document_id: document_id,
      root_layer_id: nil
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def multi(%__MODULE__{document_id: document_id, root_layer_id: root_layer_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :result,
      from(d in Document,
        as: :document,
        where: d.id == ^document_id,
        left_join: thumb in assoc(d, :thumbnail),
        as: :thumb,
        left_join: force_parent in LayerParenthood,
        as: :force_parent,
        on:
          ^case root_layer_id do
            nil ->
              dynamic(
                [force_parent: p],
                p.depth == 0 and p.document_id == ^document_id
              )

            :thumbnail ->
              dynamic(
                [thumb: thumb, force_parent: p],
                p.ancestor_id == thumb.layer_id
              )

            root when is_binary(root) ->
              dynamic(
                [force_parent: p],
                p.ancestor_id == ^root and p.document_id == ^document_id
              )
          end,
        left_join: l in assoc(d, :layers),
        on: l.id == force_parent.descendant_id,
        left_join: dp in assoc(l, :direct_parent_hood),
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
        # TODO: move this conditon "ns.predecessor_id != ns.id" into :where of the has_many association
        # of Snapshot, as soon as Ecto supports it.
        left_join: ns in assoc(cs, :successors),
        on: ns.predecessor_id != ns.id,
        order_by: [asc: l.z_index, asc: w.sort],
        preload: [
          current_snaptshot: {cs, [predecessor: ps, successors: ns]},
          thumbnail: thumb,
          layers:
            {l,
             [
               direct_parent_hood: dp,
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
