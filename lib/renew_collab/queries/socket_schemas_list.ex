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
      :result,
      from(p in SocketSchema,
        left_join: s in assoc(p, :sockets),
        order_by: [asc: p.name],
        preload: [sockets: s]
      )
    )
  end
end
