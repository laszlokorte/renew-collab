defmodule RenewCollab.Commands.SetVisibility do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id, :visible]

  def new(%{document_id: document_id, layer_id: layer_id, visible: visible}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, visible: visible}
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, visible: visible}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.update_all(
      :update_visibility,
      fn %{document_id: document_id} ->
        from(
          l in Layer,
          where: l.id == ^layer_id and l.document_id == ^document_id,
          update: [set: [hidden: not (^visible)]]
        )
      end,
      []
    )
  end
end
