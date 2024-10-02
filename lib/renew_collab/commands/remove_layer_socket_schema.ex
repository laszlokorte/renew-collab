defmodule RenewCollab.Commands.RemoveLayerSocketSchema do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  defstruct [:document_id, :layer_id]

  def new(%{
        document_id: document_id,
        layer_id: layer_id
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :interface,
      fn %{document_id: document_id} ->
        from(s in Layer,
          join: i in assoc(s, :interface),
          where: s.id == ^layer_id and s.document_id == ^document_id,
          select: i
        )
      end
    )
    |> Ecto.Multi.delete(:insert_interface, fn %{interface: interface} ->
      interface
    end)
  end
end
