defmodule RenewCollab.Repo.Migrations.UpdateDefaultPrimitiveSizes do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Primitives.PredefinedPrimitiveGroup

  def up do
    for group <- RenewCollab.Primitives.Predefined.all(),
        primitive <- Map.get(group, :primitives, []) do
      group_id =
        repo().one(
          from(g in PredefinedPrimitiveGroup,
            where: g.name == ^Map.fetch!(group, :name),
            select: g.id
          )
        )

      if group_id do
        repo().update_all(
          from(p in PredefinedPrimitive,
            where:
              p.predefined_primitive_group_id == ^group_id and
                p.name == ^Map.fetch!(primitive, :name)
          ),
          set: [data: Map.fetch!(primitive, :data), icon: Map.fetch!(primitive, :icon)]
        )
      end
    end
  end

  def down do
    :ok
  end
end
