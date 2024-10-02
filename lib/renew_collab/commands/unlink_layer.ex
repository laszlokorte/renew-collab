defmodule RenewCollab.Commands.UnlinkLayer do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.Hyperlink
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
      :hyperlink,
      fn %{document_id: document_id} ->
        from(h in Hyperlink,
          join: s in assoc(h, :source_layer),
          where: s.id == ^layer_id and s.document_id == ^document_id
        )
      end
    )
    |> Ecto.Multi.delete(
      :delete_ink,
      fn %{hyperlink: hyperlink} ->
        hyperlink
      end
    )
  end
end
