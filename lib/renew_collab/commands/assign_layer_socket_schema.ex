defmodule RenewCollab.Commands.AssignLayerSocketSchema do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Element.Interface

  defstruct [:document_id, :layer_id, :socket_schema_id]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        socket_schema_id: socket_schema_id
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      socket_schema_id: socket_schema_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        layer_id: layer_id,
        socket_schema_id: socket_schema_id
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
    |> Ecto.Multi.insert(
      :insert_interface,
      fn %{layer: layer} ->
        %Interface{}
        |> Interface.changeset(%{
          layer_id: layer.id,
          socket_schema_id: socket_schema_id
        })
      end,
      on_conflict: {:replace, [:socket_schema_id]}
    )
  end
end
