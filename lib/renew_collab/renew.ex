defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo
  alias RenewCollab.Commands

  alias RenewCollab.Document.Document
  alias RenewCollab.Document.TransientDocument

  def list_documents do
    RenewCollab.Queries.DocumentList.new()
    |> RenewCollab.Fetcher.fetch()
  end

  def count_documents do
    RenewCollab.Queries.DocumentCount.new()
    |> RenewCollab.Fetcher.fetch()
  end

  def get_document(id), do: Repo.get(Document, id)

  def get_document_with_elements(document_id) do
    %{document_id: document_id}
    |> RenewCollab.Queries.DocumentWithElements.new()
    |> RenewCollab.Fetcher.fetch()
  end

  def create_document(attrs \\ %{}, parenthoods \\ [], hyperlinks \\ [], bonds \\ []) do
    Commands.CreateDocument.new(%{
      doc: %TransientDocument{
        content: attrs,
        parenthoods: parenthoods,
        hyperlinks: hyperlinks,
        bonds: bonds
      }
    })
    |> RenewCollab.Commander.run_document_command()
    |> case do
      {:ok, %{insert_document: insert_document}} -> {:ok, insert_document}
    end
  end
end
