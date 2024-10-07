defmodule RenewCollab.Queries.SocketIdsByName do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.SocketSchema

  defstruct []

  def new() do
    %__MODULE__{}
  end

  def tags(%__MODULE__{}), do: [:symbols]

  def multi(%__MODULE__{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.all(
      :schemas,
      from(p in SocketSchema, join: s in assoc(p, :sockets), select: {{p.name, s.name}, s.id})
    )
    |> Ecto.Multi.run(:result, fn _, %{schemas: schemas} ->
      {:ok,
       schemas
       |> Map.new()}
    end)
  end
end
