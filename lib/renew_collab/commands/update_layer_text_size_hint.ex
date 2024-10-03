defmodule RenewCollab.Commands.UpdateLayerTextSizeHint do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Element.Text
  alias RenewCollab.Style.TextSizeHint

  defstruct [:document_id, :layer_id, :box]

  def new(%{document_id: document_id, layer_id: layer_id, box: box}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id, box: box}
  end

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id, box: box}) do
    Ecto.Multi.new()
  end
end
