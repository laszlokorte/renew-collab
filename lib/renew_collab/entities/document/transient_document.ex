defmodule RenewCollab.Document.TransientDocument do
  @default_name "Untitled"

  defstruct [:content, :parenthoods, :hyperlinks, :bonds]

  def update_name(%__MODULE__{content: content} = doc, updater) do
    %__MODULE__{doc | content: Map.update(content, :name, @default_name, updater)}
  end
end
