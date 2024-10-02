defmodule RenewCollab.Commands.ToggleVisible do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id, :layer_id]

  def new(%{document_id: document_id, layer_id: layer_id}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id}
  end

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id}) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.update_all(
      :update_visibility,
      fn %{document_id: document_id} ->
        from(
          l in Layer,
          where: l.id == ^layer_id and l.document_id == ^document_id,
          update: [set: [hidden: not l.hidden]]
        )
      end,
      []
    )
  end
end
