defmodule RenewCollab.Queries.SocketsById do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.Socket

  defstruct []

  def new() do
    %__MODULE__{}
  end

  def tags(%__MODULE__{}), do: [:symbols]

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :sockets,
      from(s in Socket,
        left_join: p in assoc(s, :socket_schema),
        order_by: [asc: p.name, asc: s.name],
        preload: [socket_schema: p]
      )
    )
    |> Ecto.Multi.run(:result, fn _, %{sockets: sockets} ->
      {:ok,
       sockets
       |> Enum.map(&{&1.id, &1})
       |> Map.new()}
    end)
  end
end
