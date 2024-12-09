defmodule RenewCollab.Commands.ReorderLayer do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood

  defstruct [:document_id, :layer_id, :target_layer_id, :target]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        target_layer_id: target_layer_id,
        target: {order, relative}
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id,
      target: {order, relative}
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(
        cmd = %__MODULE__{
          document_id: document_id,
          layer_id: layer_id,
          target_layer_id: target_layer_id,
          target: {order, relative}
        }
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put({cmd, :document_id}, document_id)
    |> Ecto.Multi.one({cmd, :conflict_count}, fn _ ->
      from(p in LayerParenthood,
        where: p.ancestor_id == ^layer_id and p.descendant_id == ^target_layer_id,
        select: count(p.id)
      )
    end)
    |> Ecto.Multi.run({cmd, :check_conflict}, fn
      _, %{{^cmd, :conflict_count} => 0} = changes -> {:ok, changes}
      _, %{{^cmd, :conflict_count} => c} when c > 0 -> {:error, :cyclic_hierarchy}
      _, changes -> {:error, changes}
    end)
    |> Ecto.Multi.one({cmd, :target}, fn _ ->
      case relative do
        :inside ->
          from(parent in LayerParenthood,
            join: parent_layer in Layer,
            on: parent_layer.id == parent.descendant_id,
            left_join: sibling in LayerParenthood,
            on: sibling.depth == 1 and sibling.ancestor_id == parent.ancestor_id,
            left_join: sibling_layer in Layer,
            on: sibling.descendant_id == sibling_layer.id and sibling_layer.id != ^layer_id,
            where: parent.descendant_id == ^target_layer_id,
            where: parent.depth == 0,
            group_by: parent.ancestor_id,
            select: %{
              parent_id: parent.ancestor_id,
              z_index_above: max(sibling_layer.z_index) + 1,
              z_index_below: min(sibling_layer.z_index) - 1
            }
          )

        :outside ->
          from(target_layer in Layer,
            where: target_layer.id == ^target_layer_id,
            left_join: parent in LayerParenthood,
            on: parent.depth == 1 and parent.descendant_id == target_layer.id,
            select: %{
              parent_id: parent.ancestor_id,
              z_index_above: target_layer.z_index + 1,
              z_index_below: target_layer.z_index - 1
            }
          )
      end
    end)
    |> Ecto.Multi.all({cmd, :new_parents}, fn
      %{{^cmd, :target} => %{parent_id: nil}} ->
        from(
          low in LayerParenthood,
          where: false
        )

      %{{^cmd, :target} => %{parent_id: target_parent_id}, {^cmd, :document_id} => document_id} ->
        # SELECT low.child_id,
        # high.parent_id,
        # low.depth + high.depth + 1
        # FROM site_closure low, site_closure high
        # WHERE low.parent_id = 3 AND high.child_id=5;
        from(
          low in LayerParenthood,
          join: high in LayerParenthood,
          on: true,
          where: low.ancestor_id == ^layer_id,
          where: high.descendant_id == ^target_parent_id,
          select: %{
            document_id: ^document_id,
            descendant_id: low.descendant_id,
            ancestor_id: high.ancestor_id,
            depth: low.depth + high.depth + 1
          }
        )
    end)
    |> Ecto.Multi.delete_all(
      {cmd, :delete_old_parents},
      fn
        # DELETE FROM site_closure WHERE id IN (
        # SELECT bad.id FROM site_closure ok
        # LEFT JOIN site_closure bad ON bad.child_id=ok.child_id
        # WHERE ok.parent_id=3 and ok.depth < bad.depth
        # );

        _ ->
          from(p in LayerParenthood,
            where:
              p.id in subquery(
                from(
                  copied in subquery(
                    from(ok in LayerParenthood,
                      left_join: bad in LayerParenthood,
                      on: bad.descendant_id == ok.descendant_id,
                      where: ok.ancestor_id == ^layer_id and ok.depth < bad.depth,
                      select: bad.id
                    )
                  ),
                  select: copied.id
                )
              )
          )
      end
    )
    |> Ecto.Multi.insert_all(
      {cmd, :insert_new_parents},
      LayerParenthood,
      fn
        # INSERT INTO site_closure(child_id, parent_id, depth)
        # SELECT low.child_id,
        # high.parent_id,
        # low.depth + high.depth + 1
        # FROM site_closure low, site_closure high
        # WHERE low.parent_id = 3 AND high.child_id=5;

        %{{^cmd, :new_parents} => new_parents} ->
          new_parents
          |> Enum.map(&Map.put(&1, :id, Ecto.UUID.generate()))
      end
    )
    |> Ecto.Multi.update_all(
      {cmd, :update_z_Index},
      fn
        %{{^cmd, :target} => %{z_index_above: z_index_above, z_index_below: z_index_below}} ->
          new_z_index =
            case order do
              :below -> z_index_below
              :above -> z_index_above
            end
            |> then(&if(is_nil(&1), do: 0, else: &1))

          from(
            l in Layer,
            where: l.id == ^layer_id,
            update: [set: [z_index: ^new_z_index]]
          )
      end,
      []
    )
    |> Ecto.Multi.update_all(
      {cmd, :update_others_z_Index},
      fn
        %{
          {^cmd, :target} => %{
            parent_id: parent_id,
            z_index_above: z_index_above,
            z_index_below: z_index_below
          }
        } ->
          new_z_index =
            case order do
              :below -> z_index_below
              :above -> z_index_above
            end
            |> then(&if(is_nil(&1), do: 0, else: &1))

          case parent_id do
            nil ->
              from(
                l in Layer,
                as: :l,
                where:
                  l.document_id == ^document_id and l.id != ^layer_id and
                    ((^(order == :below) and l.z_index <= ^new_z_index) or
                       (^(order == :above) and l.z_index >= ^new_z_index)) and
                    not exists(
                      from(p in LayerParenthood,
                        where:
                          p.document_id == ^document_id and
                            p.depth == 1 and p.descendant_id == parent_as(:l).id
                      )
                    ),
                update: [
                  inc: [
                    z_index:
                      ^case order do
                        :below -> -1
                        :above -> 1
                      end
                  ]
                ]
              )

            pid ->
              from(
                l in Layer,
                where:
                  l.document_id == ^document_id and l.id != ^layer_id and
                    ((^(order == :below) and l.z_index <= ^new_z_index) or
                       (^(order == :above) and l.z_index >= ^new_z_index)) and
                    l.id in subquery(
                      from(p in LayerParenthood,
                        where:
                          p.document_id == ^document_id and p.ancestor_id == ^pid and
                            p.depth == 1,
                        select: p.descendant_id
                      )
                    ),
                update: [
                  inc: [
                    z_index:
                      ^case order do
                        :below -> -1
                        :above -> 1
                      end
                  ]
                ]
              )
          end
      end,
      []
    )
    |> Ecto.Multi.merge(fn %{{^cmd, :document_id} => document_id} ->
      RenewCollab.Commands.NormalizeZIndex.new(%{document_id: document_id, ref_id: cmd})
      |> RenewCollab.Commands.NormalizeZIndex.multi()
    end)
  end

  def parse_hierarchy_position("above", "inside"), do: {:above, :inside}
  def parse_hierarchy_position("above", "outside"), do: {:above, :outside}
  def parse_hierarchy_position("below", "outside"), do: {:below, :outside}
  def parse_hierarchy_position("below", "inside"), do: {:below, :inside}
end
