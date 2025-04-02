defmodule RenewCollab.Primitives do
  import Ecto.Query, warn: false
  alias RenewCollab.Primitives.PredefinedPrimitive
  alias RenewCollab.Primitives.PredefinedPrimitiveGroup
  alias RenewCollab.Repo

  def find_all() do
    from(g in PredefinedPrimitiveGroup,
      left_join: p in assoc(g, :primitives),
      preload: [primitives: p]
    )
    |> Repo.all()
  end

  def create(params) do
    %PredefinedPrimitiveGroup{}
    |> PredefinedPrimitiveGroup.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, s} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "primitives",
          {:created, s.id}
        )

        {:ok, s}

      e ->
        e
    end
  end

  def delete_group(id) do
    from(s in PredefinedPrimitiveGroup,
      where: s.id == ^id
    )
    |> Repo.delete_all()
    |> case do
      {1, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "primitives",
          {:deleted, {:group, id}}
        )

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
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "primitives",
          {:deleted, {:primitive, id}}
        )

        :ok
    end
  end

  def create_primitive(%{"group_id" => group_id} = params) do
    %PredefinedPrimitive{predefined_primitive_group_id: group_id}
    |> PredefinedPrimitive.changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, s} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "primitives",
          {:created, s.id}
        )

        {:ok, s}

      e ->
        e
    end
  end
end
