defmodule RenewCollabWeb.ProjectDocumentJSON do
  alias RenewCollabProj.Entites.Project

  use RenewCollabWeb, :verified_routes
  alias RenewCollab.Document.Document

  @doc """
  Renders a list of document.
  """
  def index(%{documents: documents}) do
    %{
      href: url(~p"/api/documents"),
      topic: "project/fooo/documents",
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
