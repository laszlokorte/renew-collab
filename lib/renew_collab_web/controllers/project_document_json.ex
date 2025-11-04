defmodule RenewCollabWeb.ProjectDocumentJSON do
  use RenewCollabWeb, :verified_routes
  alias RenewCollab.Document.Document

  @doc """
  Renders a list of document.
  """
  def index(%{project_id: project_id, documents: documents}) do
    %{
      href: url(~p"/api/projects/#{project_id}/documents"),
      topic: "project-documents:#{project_id}",
      content: index_content(%{documents: documents}),
      links: %{
        project: %{
          method: "GET",
          id: project_id,
          href: url(~p"/api/projects/#{project_id}")
        }
      }
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
