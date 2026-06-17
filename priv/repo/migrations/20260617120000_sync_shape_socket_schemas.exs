defmodule RenewCollab.Repo.Migrations.SyncShapeSocketSchemas do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Primitives.PredefinedPrimitiveGroup

  # Re-sync the predefined shape primitives so newly created shape figures carry a
  # socket schema. Connection/Elbow connection edges bond to a real socket (the bond
  # repositioning joins on socket + socket_schema), so without one plain shapes could
  # not be connected at all.
  def up do
    for group <- RenewCollab.Primitives.Predefined.all(),
        group.name == "Shapes" do
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
