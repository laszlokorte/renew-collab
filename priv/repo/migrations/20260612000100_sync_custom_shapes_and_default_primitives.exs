defmodule RenewCollab.Repo.Migrations.SyncCustomShapesAndDefaultPrimitives do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Primitives.PredefinedPrimitiveGroup

  def up do
    RenewCollab.Symbols.ensure_custom_shapes_multi()
    |> repo().transaction()

    for group <- RenewCollab.Primitives.Predefined.all() do
      group_id = ensure_group(group)

      for primitive <- Map.get(group, :primitives, []) do
        sync_primitive(group_id, primitive)
      end
    end
  end

  def down do
    :ok
  end

  defp ensure_group(group) do
    name = Map.fetch!(group, :name)

    repo().one(
      from(g in PredefinedPrimitiveGroup,
        where: g.name == ^name,
        select: g.id
      )
    ) ||
      repo().insert!(%PredefinedPrimitiveGroup{
        id: Map.fetch!(group, :id),
        name: name
      }).id
  end

  defp sync_primitive(group_id, primitive) do
    name = Map.fetch!(primitive, :name)
    data = Map.fetch!(primitive, :data)
    icon = Map.fetch!(primitive, :icon)

    {count, _} =
      repo().update_all(
        from(p in PredefinedPrimitive, where: p.name == ^name),
        set: [
          predefined_primitive_group_id: group_id,
          data: data,
          icon: icon
        ]
      )

    if count == 0 do
      repo().insert!(%PredefinedPrimitive{
        predefined_primitive_group_id: group_id,
        name: name,
        data: data,
        icon: icon
      })
    end
  end
end
