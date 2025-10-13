defmodule RenewCollabWeb.ProjectDocumentJSON do
  use RenewCollabWeb, :verified_routes
  alias RenewCollab.Document.Document

  @doc """
  Renders a list of document.
  """
  def index(%{project_id: project_id, documents: documents}) do
    %{
      href: url(~p"/api/projects/#{project_id}/documents"),
      topic: "project/#{project_id}/documents",
      content: index_content(%{documents: documents})
    }
  end

  def index_content(%{documents: documents}) do
    %{
      items: for(document <- documents, do: list_data(document))
    }
  end

  defp list_data(%Document{} = document) do
    %{
      # id: document.id,
      href: url(~p"/api/documents/#{document}"),
      name: document.name,
      kind: document.kind,
      id: document.id,
      links: %{
        export: %{
          href: url(~p"/api/documents/#{document.id}/export")
        }
      }
    }
  end
end
