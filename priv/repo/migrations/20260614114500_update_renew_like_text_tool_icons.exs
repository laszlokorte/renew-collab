defmodule RenewCollab.Repo.Migrations.UpdateRenewLikeTextToolIcons do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Primitives.PredefinedPrimitive

  @updated_icons ["Free Text", "Connected Text", "Inscription", "Name", "Declaration", "Comment"]

  def up do
    icons_by_name =
      RenewCollab.Primitives.Predefined.all()
      |> Enum.flat_map(&Map.get(&1, :primitives, []))
      |> Map.new(fn primitive -> {Map.fetch!(primitive, :name), Map.fetch!(primitive, :icon)} end)

    for name <- @updated_icons do
      case Map.fetch(icons_by_name, name) do
        {:ok, icon} ->
          repo().update_all(
            from(p in PredefinedPrimitive, where: p.name == ^name),
            set: [icon: icon]
          )

        :error ->
          :ok
      end
    end
  end

  def down do
    :ok
  end
end
