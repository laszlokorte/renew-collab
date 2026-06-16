defmodule RenewCollab.Repo.Migrations.RenameDefaultToolsLikeRenew do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Primitives.PredefinedPrimitive

  @renames [
    {"Place", "Place Tool"},
    {"Transition", "Transition Tool"},
    {"Virtual Place", "Virtual Place Tool"},
    {"Virtual Transition", "Virtual Transition Tool"},
    {"Rectangle", "Rectangle Tool"},
    {"Round Rectangle", "Round Rectangle Tool"},
    {"Ellipse", "Ellipse Tool"},
    {"Pie Segment", "Elliptical Arc/Pie Tool"},
    {"Diamond", "Diamond Tool"},
    {"Triangle", "Triangle Tool"},
    {"Line", "Line Tool"},
    {"Target", "Target Tool"},
    {"Image", "Image Tool"},
    {"Free Text", "Text Tool"},
    {"Inscription", "Inscription Tool"},
    {"Connected Text", "Connected Text Tool"},
    {"Name", "Name Tool"},
    {"Declaration", "Declaration Tool"},
    {"Comment", "Comment Tool"},
    {"State", "FA State Tool"}
  ]

  def up do
    for {old_name, new_name} <- @renames do
      rename_primitive(old_name, new_name)
    end
  end

  def down do
    for {old_name, new_name} <- Enum.reverse(@renames) do
      rename_primitive(new_name, old_name)
    end
  end

  defp rename_primitive(old_name, new_name) do
    repo().update_all(
      from(p in PredefinedPrimitive, where: p.name == ^old_name),
      set: [name: new_name]
    )
  end
end
