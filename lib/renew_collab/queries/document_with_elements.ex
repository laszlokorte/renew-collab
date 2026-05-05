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
      :doc,
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
        left_join: cs in assoc(d, :current_snaptshot),
        order_by: [asc: l.z_index],
        preload: [
          current_snaptshot: cs,
          thumbnail: thumb,
          layers: l
        ]
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{doc: doc} ->
      {:ok,
       repo.preload(
         doc,
         [
           {:current_snaptshot, [:predecessor, :successors]},
           :thumbnail,
           layers: [
             :direct_parent_hood,
             {:box, [:symbol_shape]},
             {:text, [:style, :size_hint]},
             {:edge, [:style, :waypoints, :source_bond, :target_bond]},
             :style,
             :interface,
             :outgoing_link,
             :incoming_links
           ]
         ]
       )}
    end)
  end
end
