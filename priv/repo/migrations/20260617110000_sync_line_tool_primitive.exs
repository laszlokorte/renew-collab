defmodule RenewCollab.Repo.Migrations.SyncLineToolPrimitive do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Primitives.PredefinedPrimitive

  def up do
    RenewCollab.Primitives.Predefined.all()
    |> Enum.flat_map(&Map.get(&1, :primitives, []))
    |> Enum.find(fn primitive -> primitive.name == "Line Tool" end)
    |> sync_line_tool()
  end

  def down do
    :ok
  end

  defp sync_line_tool(nil), do: :ok

  defp sync_line_tool(primitive) do
    repo().update_all(
      from(p in PredefinedPrimitive, where: p.name == "Line Tool"),
      set: [
        data: Map.fetch!(primitive, :data),
        icon: Map.fetch!(primitive, :icon)
      ]
    )
  end
end
