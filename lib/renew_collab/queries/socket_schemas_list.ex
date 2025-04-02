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
      :schemas,
      from(p in SocketSchema,
        left_join: s in assoc(p, :sockets),
        order_by: [asc: p.name],
        preload: [sockets: s]
      )
    )
    |> Ecto.Multi.run(:result, fn _, %{schemas: schemas} ->
      {:ok,
       schemas
       |> Enum.map(&{&1.id, &1})
       |> Map.new()}
    end)
  end
end
