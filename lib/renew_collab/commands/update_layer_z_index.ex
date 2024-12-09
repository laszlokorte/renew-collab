defmodule RenewCollab.Commands.UpdateLayerZIndex do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :z_index]

  def new(%{
        document_id: document_id,
        layer_id: layer_id,
        z_index: z_index
      }) do
    %__MODULE__{
      document_id: document_id,
      layer_id: layer_id,
      z_index: z_index
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(
        cmd = %__MODULE__{
          document_id: document_id,
          layer_id: layer_id,
          z_index: z_index
        }
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(
      :layer,
      from(l in Layer, where: l.id == ^layer_id, select: l)
    )
    |> Ecto.Multi.update(
      :z_index,
      fn %{layer: layer} ->
        Layer.changeset(layer, %{
          z_index: z_index
        })
      end
    )
    |> Ecto.Multi.merge(fn %{^document_id => document_id} ->
      RenewCollab.Commands.NormalizeZIndex.new(%{document_id: document_id, ref_id: cmd})
      |> RenewCollab.Commands.NormalizeZIndex.multi()
    end)
  end
end
