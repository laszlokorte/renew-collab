defmodule RenewCollab.Primitives do
  import Ecto.Query, warn: false
  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Primitives.PredefinedPrimitiveGroup
  alias RenewCollab.Repo

  def find_all() do
    from(g in PredefinedPrimitiveGroup)
    |> Repo.all()
    |> Repo.preload([:primitives])
  end

  def create_group(params) do
    %PredefinedPrimitiveGroup{}
    |> PredefinedPrimitiveGroup.changeset(params)
    |> Repo.insert()
  end

  def delete_group(id) do
    from(s in PredefinedPrimitiveGroup,
      where: s.id == ^id
    )
    |> Repo.delete_all()
    |> case do
      {1, _} ->
        :ok
    end
  end

  def delete_primitive(id) do
    from(s in PredefinedPrimitive,
      where: s.id == ^id
    )
    |> Repo.delete_all()
    |> case do
      {1, _} ->
        :ok
    end
  end

  def create_primitive(%{"group_id" => group_id} = params) do
    %PredefinedPrimitive{predefined_primitive_group_id: group_id}
    |> PredefinedPrimitive.changeset(params)
    |> Repo.insert()
  end
end
