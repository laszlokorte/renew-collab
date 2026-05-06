defmodule RenewCollab.Queries.SocketSchemasList do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.SocketSchema

  defstruct []

  def new() do
    %__MODULE__{}
  end

  def tags(%__MODULE__{}), do: [:sockets]

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :schema,
      from(p in SocketSchema,
        order_by: [asc: p.name]
      )
    )
    |> Ecto.Multi.run(:result, fn repo, %{schema: schema} ->
      {:ok, repo.preload(schema, [:sockets])}
    end)
  end
end
