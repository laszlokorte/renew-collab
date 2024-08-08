defmodule RenewCollabWeb.DocumentJSON do
  alias RenewCollab.Document.Document
  alias RenewCollab.Element.Element
  use RenewCollabWeb, :verified_routes

  @doc """
  Renders a list of document.
  """
  def index(%{documents: documents}) do
    %{
      data: %{
        href: url(~p"/api/documents"),
        channel: "documents",
        items: for(document <- documents, do: list_data(document))
      }
    }
  end

  @doc """
  Renders a single document.
  """
  def show(%{document: document}) do
    %{data: detail_data(document)}
  end

  defp list_data(%Document{} = document) do
    %{
      # id: document.id,
      href: url(~p"/api/documents/#{document}"),
      name: document.name,
      kind: document.kind
    }
  end

  defp detail_data(%Document{} = document) do
    %{
      # id: document.id,
      href: url(~p"/api/documents/#{document}"),
      channel: "document:#{document.id}",
      name: document.name,
      kind: document.kind,
      elements:
        case document.elements do
          %Ecto.Association.NotLoaded{} -> %{}
          _ -> %{items: document.elements |> Enum.map(&element_data(document, &1))}
        end
        |> Map.put(:href, url(~p"/api/documents/#{document}/elements"))
    }
  end

  defp element_data(%Document{} = document, %Element{} = element) do
    %{
      # id: element.id,
      z_index: element.z_index,
      position_x: element.position_x,
      position_y: element.position_y
    }
  end
end
