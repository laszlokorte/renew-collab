defmodule RenewCollab.Document.TransientDocument do
  defstruct [:content, :parenthoods, :hyperlinks, :bonds]

  def update_name(%__MODULE__{content: content} = doc, updater) do
    %__MODULE__{doc | content: Map.update(content, :name, "Untitled", updater)}
  end
end
