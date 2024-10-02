defmodule RenewCollab.Commands.LinkLayer do
  import Ecto.Query, warn: false
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Hyperlink

  defstruct [:document_id, :layer_id, :target_layer_id]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        target_layer_id: target_layer_id
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      target_layer_id: target_layer_id
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        target_layer_id: target_layer_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :layer,
      fn %{document_id: document_id} ->
        from(s in Layer,
          where: s.id == ^layer_id and s.document_id == ^document_id
        )
      end
    )
    |> Ecto.Multi.insert(:insert_hyperlink, fn %{layer: layer} ->
      %Hyperlink{}
      |> Hyperlink.changeset(%{
        source_layer_id: layer.id,
        target_layer_id: target_layer_id
      })
    end)
  end
end
