defmodule RenewCollab.Repo.Migrations.UpdateTargetToolIcon do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Primitives.Predefined
  alias RenewCollab.Primitives.PredefinedPrimitive

  def up do
    icon =
      Predefined.all()
      |> Enum.flat_map(&Map.get(&1, :primitives, []))
      |> Enum.find(&(Map.fetch!(&1, :name) == "Target Tool"))
      |> Map.fetch!(:icon)

    repo().update_all(
      from(p in PredefinedPrimitive, where: p.name == "Target Tool"),
      set: [icon: icon]
    )
  end

  def down, do: :ok
end
