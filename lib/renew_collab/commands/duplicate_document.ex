defmodule RenewCollab.Commands.DuplicateDocument do
  alias __MODULE__

  import Ecto.Query, warn: false
  alias RenewCollab.Document.Document

  defstruct [:document_id]
end
