defmodule RenewCollab.Commands.DuplicateDocument do
  import Ecto.Query, warn: false

  defstruct [:document_id]

  def new(%{document_id: document_id}) do
    %__MODULE__{document_id: document_id}
  end

  def multi(%__MODULE__{document_id: id}) do
    RenewCollab.Clone.deep_clone_document_multi(id)
    |> Ecto.Multi.merge(fn %{cloned: {attrs, parenthoods, hyperlinks, bonds}} ->
      RenewCollab.Commands.CreateDocument.new(%{
        attrs:
          attrs |> Map.update(:name, "Untitled", &"#{String.trim_trailing(&1, "(Copy)")} (Copy)"),
        parenthoods: parenthoods,
        hyperlinks: hyperlinks,
        bonds: bonds
      })
      |> RenewCollab.Commands.CreateDocument.multi()
    end)
  end
end
