defmodule RenewCollab.Repo.Migrations.SyncRenewLikeToolIcons do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Primitives.Predefined
  alias RenewCollab.Primitives.PredefinedPrimitive

  def up do
    Predefined.all()
    |> Enum.flat_map(&Map.get(&1, :primitives, []))
    |> Enum.each(fn primitive ->
      from(p in PredefinedPrimitive, where: p.name == ^primitive.name)
      |> repo().update_all(set: [icon: primitive.icon])
    end)
  end

  def down, do: :ok
end
